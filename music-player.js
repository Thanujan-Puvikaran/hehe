/**
 * Music Player Module
 * Self-hosted MP3 scroll-based playback with playlist, section, shuffle.
 *
 * Features:
 * - Playlist with sequential/shuffle playback
 * - Section-based track switching on scroll
 * - Fade in/out volume transitions
 * - Mute/unmute toggle with localStorage persistence
 * - Respects browser autoplay policies
 */

const MusicPlayer = (() => {
  "use strict";

  const TRACKS = [
    { src: "music/track1.mp3", title: "Track 1", sectionStart: 0.0, sectionEnd: 0.33 },
    { src: "music/track2.mp3", title: "Track 2", sectionStart: 0.33, sectionEnd: 0.66 },
    { src: "music/track3.mp3", title: "Track 3", sectionStart: 0.66, sectionEnd: 1.0 },
  ];

  const FADE_DURATION_MS = 1500;
  const FADE_INTERVAL_MS = 50;
  const MAX_VOLUME = 0.6;

  let audioElement = null;
  let currentTrackIndex = -1;
  let isMuted = false;
  let isPlaying = false;
  let hasUserInteracted = false;
  let shuffledOrder = [];
  let shufflePosition = 0;
  let fadeInterval = null;
  let muteButton = null;
  let trackInfoElement = null;

  /** Generate shuffled track order using Fisher-Yates with date-based seed. */
  function generateShuffledOrder() {
    const indices = TRACKS.map((_, i) => i);
    const seed = new Date().toDateString();
    let seedHash = 0;
    for (let i = 0; i < seed.length; i++) {
      seedHash = ((seedHash << 5) - seedHash) + seed.charCodeAt(i);
      seedHash = seedHash & seedHash;
    }
    let rng = Math.abs(seedHash);
    for (let i = indices.length - 1; i > 0; i--) {
      rng = (rng * 16807 + 0) % 2147483647;
      const j = rng % (i + 1);
      [indices[i], indices[j]] = [indices[j], indices[i]];
    }
    return indices;
  }

  /** Create the audio element if it does not exist. */
  function ensureAudioElement() {
    if (!audioElement) {
      audioElement = new Audio();
      audioElement.loop = false;
      audioElement.volume = 0;
      audioElement.preload = "auto";
      audioElement.addEventListener("ended", () => { playNextTrack(); });
      audioElement.addEventListener("error", (e) => {
        console.warn("Music player: failed to load track", TRACKS[currentTrackIndex]?.src, e);
        playNextTrack();
      });
    }
  }

  /**
   * Fade volume from current level to target level.
   * @param {number} targetVolume - Target volume (0.0 to 1.0).
   * @param {Function} [onComplete] - Callback when fade completes.
   */
  function fadeVolumeTo(targetVolume, onComplete) {
    if (fadeInterval) clearInterval(fadeInterval);
    if (!audioElement || isMuted) {
      if (audioElement) audioElement.volume = isMuted ? 0 : targetVolume;
      if (onComplete) onComplete();
      return;
    }
    const startVolume = audioElement.volume;
    const steps = FADE_DURATION_MS / FADE_INTERVAL_MS;
    const volumeStep = (targetVolume - startVolume) / steps;
    let currentStep = 0;
    fadeInterval = setInterval(() => {
      currentStep++;
      const newVolume = startVolume + (volumeStep * currentStep);
      audioElement.volume = Math.max(0, Math.min(1, newVolume));
      if (currentStep >= steps) {
        clearInterval(fadeInterval);
        fadeInterval = null;
        audioElement.volume = Math.max(0, Math.min(1, targetVolume));
        if (onComplete) onComplete();
      }
    }, FADE_INTERVAL_MS);
  }

  /**
   * Load and play a specific track by index with crossfade.
   * @param {number} trackIndex - Index of the track in TRACKS array.
   */
  function loadAndPlayTrack(trackIndex) {
    if (trackIndex < 0 || trackIndex >= TRACKS.length) return;
    if (trackIndex === currentTrackIndex && isPlaying) return;
    ensureAudioElement();
    const track = TRACKS[trackIndex];
    const wasPlaying = isPlaying;
    const startPlay = () => {
      currentTrackIndex = trackIndex;
      audioElement.src = track.src;
      audioElement.play().then(() => {
        isPlaying = true;
        fadeVolumeTo(isMuted ? 0 : MAX_VOLUME);
        updateTrackInfo();
      }).catch((err) => {
        console.warn("Music player: autoplay blocked or error", err);
        isPlaying = false;
      });
    };
    if (wasPlaying && currentTrackIndex !== trackIndex) {
      fadeVolumeTo(0, startPlay);
    } else {
      startPlay();
    }
  }

  /** Play the next track in shuffled order. */
  function playNextTrack() {
    if (shuffledOrder.length === 0) {
      shuffledOrder = generateShuffledOrder();
      shufflePosition = 0;
    }
    shufflePosition = (shufflePosition + 1) % shuffledOrder.length;
    loadAndPlayTrack(shuffledOrder[shufflePosition]);
  }

  /** @returns {number} Scroll progress 0-1. */
  function getScrollProgress() {
    const scrollTop = window.scrollY || document.documentElement.scrollTop;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    if (docHeight <= 0) return 0;
    return Math.max(0, Math.min(1, scrollTop / docHeight));
  }

  /** @returns {number} Track index for current scroll, or -1. */
  function getTrackForScrollPosition() {
    const progress = getScrollProgress();
    for (let i = 0; i < TRACKS.length; i++) {
      if (progress >= TRACKS[i].sectionStart && progress < TRACKS[i].sectionEnd) return i;
    }
    return -1;
  }

  /** Handle scroll event to switch tracks based on position. */
  function handleScroll() {
    if (!hasUserInteracted) return;
    if (!isPlaying && getScrollProgress() > 0.01) {
      const idx = getTrackForScrollPosition();
      loadAndPlayTrack(idx >= 0 ? idx : (shuffledOrder[shufflePosition] || 0));
      return;
    }
    const target = getTrackForScrollPosition();
    if (target >= 0 && target !== currentTrackIndex) loadAndPlayTrack(target);
  }

  /** Create the mute/unmute toggle button matching site theme. */
  function createMuteButton() {
    muteButton = document.createElement("button");
    muteButton.id = "musicToggle";
    muteButton.setAttribute("aria-label", "Toggle music");
    muteButton.innerHTML = isMuted ? "\ud83d\udd07" : "\ud83d\udd0a";
    Object.assign(muteButton.style, {
      position: "fixed", bottom: "30px", left: "30px", zIndex: "1000",
      width: "50px", height: "50px", borderRadius: "50%",
      border: "1px solid rgba(255,255,255,0.10)",
      background: "rgba(255,255,255,0.05)",
      backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
      color: "rgba(255,255,255,0.92)", fontSize: "1.3em", cursor: "pointer",
      transition: "all 0.3s ease", display: "flex",
      alignItems: "center", justifyContent: "center",
      boxShadow: "0 18px 60px rgba(0,0,0,0.55)",
    });
    muteButton.addEventListener("mouseenter", () => {
      muteButton.style.background = "rgba(255,255,255,0.10)";
      muteButton.style.transform = "translateY(-2px)";
    });
    muteButton.addEventListener("mouseleave", () => {
      muteButton.style.background = "rgba(255,255,255,0.05)";
      muteButton.style.transform = "translateY(0)";
    });
    muteButton.addEventListener("click", toggleMute);
    document.body.appendChild(muteButton);

    trackInfoElement = document.createElement("div");
    trackInfoElement.id = "trackInfo";
    Object.assign(trackInfoElement.style, {
      position: "fixed", bottom: "90px", left: "30px", zIndex: "1000",
      padding: "8px 16px", borderRadius: "12px",
      border: "1px solid rgba(255,255,255,0.10)",
      background: "rgba(255,255,255,0.05)",
      backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
      color: "rgba(255,255,255,0.62)",
      fontFamily: "Inter,-apple-system,sans-serif",
      fontSize: "0.8em", letterSpacing: "0.02em",
      opacity: "0", transition: "opacity 0.5s ease", pointerEvents: "none",
    });
    document.body.appendChild(trackInfoElement);
  }

  /** Toggle mute state and persist preference in localStorage. */
  function toggleMute() {
    hasUserInteracted = true;
    isMuted = !isMuted;
    localStorage.setItem("musicMuted", isMuted ? "true" : "false");
    if (muteButton) muteButton.innerHTML = isMuted ? "\ud83d\udd07" : "\ud83d\udd0a";
    if (audioElement) {
      if (isMuted) {
        fadeVolumeTo(0);
      } else {
        fadeVolumeTo(MAX_VOLUME);
        if (!isPlaying) {
          const idx = getTrackForScrollPosition();
          loadAndPlayTrack(idx >= 0 ? idx : (shuffledOrder[0] || 0));
        }
      }
    }
  }

  /** Update the track info tooltip. */
  function updateTrackInfo() {
    if (!trackInfoElement || currentTrackIndex < 0) return;
    trackInfoElement.textContent = "\u266a " + TRACKS[currentTrackIndex].title;
    trackInfoElement.style.opacity = "1";
    setTimeout(() => { if (trackInfoElement) trackInfoElement.style.opacity = "0"; }, 3000);
  }

  /** Initialize the music player. */
  function init() {
    isMuted = localStorage.getItem("musicMuted") === "true";
    shuffledOrder = generateShuffledOrder();
    shufflePosition = 0;
    createMuteButton();
    ensureAudioElement();
    let scrollTimeout = null;
    window.addEventListener("scroll", () => {
      if (scrollTimeout) clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(handleScroll, 150);
    }, { passive: true });
    const events = ["click", "touchstart", "keydown"];
    const onFirst = () => {
      hasUserInteracted = true;
      events.forEach(e => document.removeEventListener(e, onFirst));
      if (getScrollProgress() > 0.01 && !isPlaying && !isMuted) handleScroll();
    };
    events.forEach(e => document.addEventListener(e, onFirst, { once: false }));
  }

  return { init, toggleMute, setTracks(t) { TRACKS.length=0; TRACKS.push(...t); shuffledOrder=generateShuffledOrder(); shufflePosition=0; } };
})();

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", MusicPlayer.init);
} else {
  MusicPlayer.init();
}
