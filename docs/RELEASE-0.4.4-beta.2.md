# RB_ASCII Native 0.4.4 beta 2 · Release notes

This is the first public RB_ASCII package in the `luoboruodai/RB_ASCII` repository. It is the renamed continuation of the local CharWeave 0.4.4 beta 2 implementation.

## Identity

- Visible product: **RB_ASCII Native**
- Release tag: `rb-ascii-v0.4.4-beta.2`
- PF/PiPL version: `0x00022402`
- macOS bundle build: `40402`
- macOS bundle identifier: `com.rbascii.native`
- Legacy AE match name: `CW CharWeave Native` (preserved intentionally for existing project resolution)

## Assets

| Asset | SHA-256 |
| --- | --- |
| `RB_ASCII-0.4.4-b2-macOS.zip` | `a7f55e824cbc9fdce61c61f0975c83490b5ca9fc46710513c503c159797ad97a` |
| `RB_ASCII-0.4.4-b2-Windows-x64.zip` | `0bc23f090aa6942d7b47160d3d5afb3b87682470c94126345dc49d9b7dd4e561` |

The release also includes `RB_ASCII-0.4.4-b2-source.zip` and `SHA256SUMS.txt`.

## Verification boundary

- macOS: universal arm64/x86_64 build, ad-hoc signature, PiPL/resource identity, local Apple Silicon AE 26.5x89 registration and sample-frame export after replacement.
- Windows: PE32+ x86-64, `DllMain`/`EffectMain` exports, PiPL identity, loader imports and 12 GDI behavior-model cases.
- Windows AE startup, rendering, font pixels and host acceptance were not available on this machine and remain unverified.
- No Developer ID/notarization or Windows Authenticode signature is claimed.

Do not install both the renamed RB_ASCII bundle and an old CharWeave bundle in AE scan paths. The installer backs up recognized old copies outside the scan path.
