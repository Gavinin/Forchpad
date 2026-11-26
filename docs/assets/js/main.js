/* Forchpad site — interactions: reveals, marquee, pad demo, latest-release wiring. */

(function () {
  "use strict";

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- nav shade on scroll ---------- */
  const nav = document.getElementById("nav");
  const onScroll = () => nav.classList.toggle("scrolled", window.scrollY > 8);
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  /* ---------- reveal on scroll ---------- */
  document.querySelectorAll("[data-i18n-delay]").forEach((el) => {
    el.style.setProperty("--d", el.getAttribute("data-i18n-delay"));
  });
  const io = new IntersectionObserver(
    (entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add("visible");
          io.unobserve(e.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: "0px 0px -6% 0px" }
  );
  document.querySelectorAll(".reveal").forEach((el) => io.observe(el));

  /* ---------- marquee: clone content for a seamless loop ---------- */
  const track = document.getElementById("marqueeTrack");
  if (track) track.innerHTML += track.innerHTML;

  /* ---------- hero glow follows the pointer ---------- */
  const hero = document.querySelector(".hero");
  const glow = document.getElementById("heroGlow");
  if (hero && glow && !reducedMotion) {
    hero.addEventListener("pointermove", (e) => {
      const r = hero.getBoundingClientRect();
      const x = ((e.clientX - r.left) / r.width - 0.5) * 90;
      const y = ((e.clientY - r.top) / r.height - 0.5) * 50;
      glow.style.transform = `translate(${x}px, ${y}px)`;
    });
  }

  /* ---------- pad window tilt ---------- */
  const padWindow = document.getElementById("padWindow");
  const demo = document.querySelector(".demo");
  if (padWindow && demo && !reducedMotion) {
    demo.addEventListener("pointermove", (e) => {
      const r = padWindow.getBoundingClientRect();
      const dx = (e.clientX - (r.left + r.width / 2)) / r.width;
      const dy = (e.clientY - (r.top + r.height / 2)) / r.height;
      padWindow.style.setProperty("--ry", `${Math.max(-0.7, Math.min(0.7, dx)) * 9}deg`);
      padWindow.style.setProperty("--rx", `${Math.max(-0.7, Math.min(0.7, -dy)) * 7}deg`);
    });
    demo.addEventListener("pointerleave", () => {
      padWindow.style.setProperty("--rx", "0deg");
      padWindow.style.setProperty("--ry", "0deg");
    });
  }

  /* ---------- interactive pad demo ---------- */
  const pads = Array.from(document.querySelectorAll(".pad"));
  const grid = document.getElementById("padGrid");

  // C minor pentatonic across two octaves — anything you tap sounds intentional.
  const SCALE = [48, 50, 53, 55, 58, 60, 62, 65, 67];
  const freq = (midi) => 440 * Math.pow(2, (midi - 69) / 12);

  let audio = null;
  function ensureAudio() {
    if (audio) return audio;
    const Ctx = window.AudioContext || window.webkitAudioContext;
    if (!Ctx) return null;
    audio = new Ctx();
    return audio;
  }

  function pluck(midi) {
    const ctx = ensureAudio();
    if (!ctx) return;
    if (ctx.state === "suspended") ctx.resume();
    const t = ctx.currentTime;
    const f = freq(midi);

    const out = ctx.createGain();
    out.gain.setValueAtTime(0, t);
    out.gain.linearRampToValueAtTime(0.16, t + 0.008);
    out.gain.exponentialRampToValueAtTime(0.0001, t + 0.85);
    out.connect(ctx.destination);

    const body = ctx.createOscillator(); // warm mallet body
    body.type = "triangle";
    body.frequency.value = f;
    body.connect(out);

    const ping = ctx.createOscillator(); // a little glass on top
    ping.type = "sine";
    ping.frequency.value = f * 2;
    const pingGain = ctx.createGain();
    pingGain.gain.setValueAtTime(0.05, t);
    pingGain.gain.exponentialRampToValueAtTime(0.0001, t + 0.3);
    ping.connect(pingGain).connect(out);

    body.start(t); body.stop(t + 0.9);
    ping.start(t); ping.stop(t + 0.35);
  }

  let userTouched = false;
  let autoplayTimer = null;
  let idleTimer = null;

  const active = new Map(); // pointerId -> pad index

  function padOn(pad) {
    pad.classList.add("on");
    pluck(SCALE[Number(pad.dataset.pad)]);
  }
  function padOff(pad) {
    pad.classList.remove("on", "auto");
  }

  if (grid) {
    grid.addEventListener("contextmenu", (e) => e.preventDefault());
    grid.addEventListener("pointerdown", (e) => {
      const pad = e.target.closest(".pad");
      if (!pad) return;
      e.preventDefault();
      userTouched = true;
      stopAutoplay();
      armIdle();
      const idx = Number(pad.dataset.pad);
      active.set(e.pointerId, idx);
      padOn(pad);
      try { grid.setPointerCapture(e.pointerId); } catch (err) { /* ok */ }
    });
    const release = (e) => {
      const idx = active.get(e.pointerId);
      if (idx === undefined) return;
      active.delete(e.pointerId);
      const pad = pads[idx];
      // only darken when no other pointer holds it
      if (![...active.values()].includes(idx)) padOff(pad);
    };
    grid.addEventListener("pointerup", release);
    grid.addEventListener("pointercancel", release);
    grid.addEventListener("pointermove", (e) => {
      const held = active.get(e.pointerId);
      if (held === undefined) return;
      const el = document.elementFromPoint(e.clientX, e.clientY);
      const pad = el && el.closest ? el.closest(".pad") : null;
      const now = pad ? Number(pad.dataset.pad) : -1;
      if (now === held) return;
      if (![...active.values()].includes(held)) padOff(pads[held]);
      active.delete(e.pointerId);
      if (pad) {
        active.set(e.pointerId, now);
        padOn(pad);
      }
    });
  }

  /* ---------- idle autoplay: a quiet loop until a visitor plays ---------- */
  const PATTERN = [6, 4, 2, 4, 7, 4, 2, 5, 6, 4, 2, 4, 8, 3, 0, 4];
  let step = 0;
  function startAutoplay() {
    if (reducedMotion || autoplayTimer || userTouched || active.size) return;
    autoplayTimer = setInterval(() => {
      const pad = pads[PATTERN[step % PATTERN.length]];
      step += 1;
      if (!pad || pad.classList.contains("on")) return;
      pad.classList.add("auto");
      setTimeout(() => pad.classList.remove("auto"), 260);
    }, 340);
  }
  function stopAutoplay() {
    clearInterval(autoplayTimer);
    autoplayTimer = null;
    // only clear the loop's own lights — never pads a visitor is holding down
    pads.forEach((p) => p.classList.remove("auto"));
  }
  function armIdle() {
    clearTimeout(idleTimer);
    idleTimer = setTimeout(() => {
      userTouched = false;
      startAutoplay();
    }, 12000);
  }
  document.addEventListener("visibilitychange", () => {
    if (document.hidden) stopAutoplay();
    else if (!userTouched) startAutoplay();
  });
  // start when the demo scrolls into view
  if (demo) {
    const demoIO = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          startAutoplay();
          demoIO.disconnect();
        }
      });
    }, { threshold: 0.4 });
    demoIO.observe(demo);
  }

  /* ---------- latest release: wire download buttons to the newest zip ---------- */
  const FALLBACK = "https://github.com/Gavinin/Forchpad/releases/latest";
  const REL_CACHE = "forchpad-release";

  function wireRelease(rel) {
    const zip = (rel.assets || []).find((a) => /\.zip$/i.test(a.name));
    const href = zip ? zip.browser_download_url : rel.html_url || FALLBACK;
    document.querySelectorAll(".js-download").forEach((a) => { a.href = href; });
    const pill = document.getElementById("versionPill");
    const text = document.getElementById("versionText");
    if (pill && text && rel.tag_name) {
      const mb = zip && zip.size ? ` · ${(zip.size / 1048576).toFixed(1)} MB` : "";
      text.textContent = `${rel.tag_name}${mb}`;
      pill.hidden = false;
    }
  }

  // paint from cache instantly, then refresh from the API — rate limits can't hurt
  try {
    const cached = JSON.parse(localStorage.getItem(REL_CACHE) || "null");
    if (cached && cached.tag_name) wireRelease(cached);
  } catch (e) { /* private mode */ }

  fetch("https://api.github.com/repos/Gavinin/Forchpad/releases/latest")
    .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
    .then((rel) => {
      wireRelease(rel);
      try {
        localStorage.setItem(REL_CACHE, JSON.stringify({
          tag_name: rel.tag_name,
          html_url: rel.html_url,
          assets: (rel.assets || []).map((a) => ({ name: a.name, browser_download_url: a.browser_download_url, size: a.size })),
        }));
      } catch (e) { /* private mode */ }
    })
    .catch(() => { /* offline or rate-limited: the releases/latest fallback stays */ });

  /* ---------- footer year ---------- */
  const year = document.getElementById("year");
  if (year) year.textContent = String(new Date().getFullYear());
})();
