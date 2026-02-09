"""
Unit tests for the secure server module.
Tests cover session management, authentication, and HTTP request handling.
All tests are deterministic and use mocked dependencies.
"""

import server
import unittest
from unittest.mock import patch, MagicMock, mock_open
import sys
import os
from datetime import datetime, timedelta
from io import BytesIO

# Add the parent directory to sys.path to import server
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Mock the modules before importing server
sys.modules["http"] = MagicMock()
sys.modules["http.server"] = MagicMock()
sys.modules["socketserver"] = MagicMock()


class TestSessionManagement(unittest.TestCase):
    """Test session token generation and validation."""

    def setUp(self):
        """Reset session state before each test."""
        server.active_session["token"] = None
        server.active_session["expires_at"] = None
        server.active_session["ip_address"] = None

    def test_generate_session_token_returns_string(self):
        """Test that generate_session_token returns a non-empty string."""
        token = server.generate_session_token()
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 0)

    def test_generate_session_token_unique(self):
        """Test that generate_session_token produces unique tokens."""
        token1 = server.generate_session_token()
        token2 = server.generate_session_token()
        self.assertNotEqual(token1, token2)

    def test_create_session_sets_token(self):
        """Test that create_session sets a token for the client IP."""
        client_ip = "192.168.1.100"
        with patch("server.datetime") as mock_datetime:
            now = datetime(2026, 2, 9, 12, 0, 0)
            mock_datetime.datetime.now.return_value = now
            mock_datetime.timedelta = timedelta

            token = server.create_session(client_ip)

            self.assertIsNotNone(server.active_session["token"])
            self.assertEqual(server.active_session["token"], token)
            self.assertEqual(server.active_session["ip_address"], client_ip)
            self.assertEqual(
                server.active_session["expires_at"], now + timedelta(minutes=60))

    def test_is_session_valid_returns_false_when_no_token(self):
        """Test that is_session_valid returns False when no session exists."""
        result = server.is_session_valid("any_token", "192.168.1.100")
        self.assertFalse(result)

    def test_is_session_valid_returns_false_for_wrong_token(self):
        """Test that is_session_valid returns False for incorrect token."""
        server.active_session["token"] = "correct_token"
        server.active_session["ip_address"] = "192.168.1.100"
        server.active_session["expires_at"] = datetime.now() + \
            timedelta(minutes=30)

        result = server.is_session_valid("wrong_token", "192.168.1.100")
        self.assertFalse(result)

    def test_is_session_valid_returns_false_for_wrong_ip(self):
        """Test that is_session_valid returns False for different IP address."""
        token = "valid_token"
        server.active_session["token"] = token
        server.active_session["ip_address"] = "192.168.1.100"
        server.active_session["expires_at"] = datetime.now() + \
            timedelta(minutes=30)

        result = server.is_session_valid(token, "192.168.1.200")
        self.assertFalse(result)

    def test_is_session_valid_returns_false_when_expired(self):
        """Test that is_session_valid returns False for expired session."""
        token = "valid_token"
        client_ip = "192.168.1.100"
        server.active_session["token"] = token
        server.active_session["ip_address"] = client_ip

        with patch("server.datetime") as mock_datetime:
            past_time = datetime(2026, 2, 9, 10, 0, 0)
            current_time = datetime(2026, 2, 9, 12, 0, 0)
            server.active_session["expires_at"] = past_time
            mock_datetime.datetime.now.return_value = current_time

            result = server.is_session_valid(token, client_ip)
            self.assertFalse(result)
            self.assertIsNone(server.active_session["token"])

    def test_is_session_valid_returns_true_for_valid_session(self):
        """Test that is_session_valid returns True for valid session."""
        token = "valid_token"
        client_ip = "192.168.1.100"
        server.active_session["token"] = token
        server.active_session["ip_address"] = client_ip

        with patch("server.datetime") as mock_datetime:
            current_time = datetime(2026, 2, 9, 12, 0, 0)
            future_time = datetime(2026, 2, 9, 13, 0, 0)
            server.active_session["expires_at"] = future_time
            mock_datetime.datetime.now.return_value = current_time

            result = server.is_session_valid(token, client_ip)
            self.assertTrue(result)


class TestPasswordRetrieval(unittest.TestCase):
    """Test password retrieval from environment variables."""

    def test_get_secret_password_returns_password_when_set(self):
        """Test that get_secret_password returns the password from env var."""
        with patch.dict(os.environ, {"BIRTHDAY_PAGE_PASSWORD": "test_password"}):
            password = server.get_secret_password()
            self.assertEqual(password, "test_password")

    def test_get_secret_password_raises_error_when_not_set(self):
        """Test that get_secret_password raises RuntimeError when env var is not set."""
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaises(RuntimeError) as context:
                server.get_secret_password()
            self.assertIn("BIRTHDAY_PAGE_PASSWORD", str(context.exception))


class TestHTTPRequestHandler(unittest.TestCase):
    """Test HTTP request handling logic."""

    def setUp(self):
        """Set up test fixtures."""
        self.handler = MagicMock()
        self.handler.client_address = ("192.168.1.100", 12345)
        self.handler.headers = MagicMock()
        self.handler.path = "/"
        self.handler.wfile = BytesIO()
        server.active_session["token"] = None
        server.active_session["expires_at"] = None
        server.active_session["ip_address"] = None

    def test_send_login_page_loads_public_template(self):
        """Test that send_login_page loads the correct public login template."""
        mock_html = "<html><body>Public Login</body></html>"
        with patch("builtins.open", mock_open(read_data=mock_html)):
            # Create handler without calling __init__
            handler = object.__new__(server.SecureHTTPRequestHandler)
            handler.send_response = MagicMock()
            handler.send_header = MagicMock()
            handler.end_headers = MagicMock()
            handler.wfile = BytesIO()

            handler.send_login_page("public")

            self.assertIn(b"Public Login", handler.wfile.getvalue())

    def test_send_login_page_loads_admin_template(self):
        """Test that send_login_page loads the correct admin login template."""
        mock_html = "<html><body>Admin Login</body></html>"
        with patch("builtins.open", mock_open(read_data=mock_html)):
            # Create handler without calling __init__
            handler = object.__new__(server.SecureHTTPRequestHandler)
            handler.send_response = MagicMock()
            handler.send_header = MagicMock()
            handler.end_headers = MagicMock()
            handler.wfile = BytesIO()

            handler.send_login_page("admin")

            self.assertIn(b"Admin Login", handler.wfile.getvalue())

    def test_send_error_page_renders_template_with_data(self):
        """Test that send_error_page renders error template with title and message."""
        mock_html = "<html><body><h1>{{title}}</h1><p>{{message}}</p></body></html>"
        with patch("builtins.open", mock_open(read_data=mock_html)):
            # Create handler without calling __init__
            handler = object.__new__(server.SecureHTTPRequestHandler)
            handler.send_response = MagicMock()
            handler.send_header = MagicMock()
            handler.end_headers = MagicMock()
            handler.wfile = BytesIO()

            handler.send_error_page("Error Title", "Error Message")

            output = handler.wfile.getvalue()
            self.assertIn(b"Error Title", output)
            self.assertIn(b"Error Message", output)
            self.assertNotIn(b"{{title}}", output)
            self.assertNotIn(b"{{message}}", output)


if __name__ == "__main__":
    unittest.main()
