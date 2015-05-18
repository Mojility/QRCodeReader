# QRCodeReader

Sample code to read 2D QR barcodes using stock iOS APIs

When we build barcode integration to customer apps, we'll tend to start from a foundation like this.

This is just baseline code, it doesn't decorate located regions in any way, and is hard-wired to only recognize QR codes in the stream. It does works out a couple fine points, such as adapting to device rotation.

This pretty much deprecates older techniques we've used over the years like RedLaser.
