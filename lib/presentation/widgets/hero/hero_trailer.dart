// lib/presentation/widgets/hero/hero_trailer.dart
//
// HeroTrailer — webview_flutter wrapper that embeds the YouTube IFrame
// Player API. Used by HeroSlide as the layer that fades in over the
// static backdrop 2 seconds after the page loads.
//
// Design contract:
//   - autoplay=1, mute starts at widget.muted (controllable via setMuted)
//   - controls=0 / modestbranding=1 / iv_load_policy=3 / disablekb=1 / fs=0
//     so the iframe looks like a pure background video, never like YouTube
//   - the whole WebViewWidget is wrapped in IgnorePointer so taps never
//     reach the iframe (the user controls mute via the parent's 🔊 button)
//   - transparent background so the backdrop image shows through during
//     the initial load + any black-frame moments between video segments
//
// The setMuted() method on State<HeroTrailer> is the only public side-
// effect — HeroSlide calls it via a GlobalKey<HeroTrailerState>.
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HeroTrailer extends StatefulWidget {
  const HeroTrailer({
    super.key,
    required this.videoId,
    this.muted = true,
  });

  /// YouTube video id (the ``v=`` param on watch URLs).
  final String videoId;

  /// Initial mute state — does NOT rebuild the player on change; use the
  /// public [HeroTrailerState.setMuted] for runtime toggling.
  final bool muted;

  @override
  State<HeroTrailer> createState() => HeroTrailerState();
}

class HeroTrailerState extends State<HeroTrailer> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    // WebViewController binds to the platform's WebViewPlatform on
    // construction. In flutter_test no platform is registered, so the
    // constructor throws — we swallow that here and fall back to a
    // transparent placeholder, which lets widget tests cover layout
    // without spinning up a real WebView.
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadHtmlString(_html(widget.videoId, widget.muted));
    } catch (_) {
      _controller = null;
    }
  }

  /// HTML payload that mounts the YouTube IFrame Player API and exposes a
  /// global ``setMuted(bool)`` function the Dart side can call via
  /// ``runJavaScript``.
  ///
  /// The iframe is sized to fill the WebView via 100% width/height +
  /// ``overflow: hidden`` on body to crop the 16:9 letterbox bars.
  static String _html(String videoId, bool muted) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <style>
    html, body { margin:0; padding:0; background:transparent; overflow:hidden; height:100%; }
    #p, #p iframe { width:100%; height:100%; border:0; display:block; }
  </style>
</head>
<body>
  <div id="p"></div>
  <script src="https://www.youtube.com/iframe_api"></script>
  <script>
    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('p', {
        videoId: '$videoId',
        width: '100%',
        height: '100%',
        playerVars: {
          autoplay: 1,
          mute: ${muted ? 1 : 0},
          controls: 0,
          modestbranding: 1,
          playsinline: 1,
          rel: 0,
          iv_load_policy: 3,
          disablekb: 1,
          fs: 0,
          loop: 1,
          playlist: '$videoId'
        },
        events: {
          'onReady': function (e) {
            ${muted ? 'e.target.mute();' : 'e.target.unMute();'}
            e.target.playVideo();
          },
          'onStateChange': function (e) {
            // YT.PlayerState.ENDED === 0 — restart so the trailer loops
            // even when YouTube ignores the loop playerVar (some titles
            // disable looping on the embed).
            if (e.data === 0) { e.target.playVideo(); }
          }
        }
      });
    }
    function setMuted(m) {
      if (!player) return;
      if (m) { player.mute(); } else { player.unMute(); }
    }
  </script>
</body>
</html>
''';

  /// Push a new mute state to the YouTube player. Safe to call before the
  /// iframe is ready — the JS guards on ``player`` being defined.
  Future<void> setMuted(bool muted) async {
    final c = _controller;
    if (c == null) return;
    await c.runJavaScript('setMuted(${muted ? 'true' : 'false'})');
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      // Test environment or platform without a WebView — render a
      // transparent placeholder so HeroSlide layout still tests cleanly.
      return const SizedBox.expand();
    }
    // IgnorePointer — taps on the trailer area must reach the parent
    // (which uses them to pause auto-rotation), and we never want the
    // user accidentally clicking into the YouTube UI.
    return IgnorePointer(
      child: WebViewWidget(controller: c),
    );
  }
}
