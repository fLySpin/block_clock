/*--------------------------------------------------------------------------------
Copyright 2020 John Lee. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * The name of John Lee may not be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

// Sizing, position and colors of the entire UI (blocks, lines and text) are
// determined by these values. They are scaled to fit screen/window size.
class BlockConfig {
  // The size of this screen/window on which to paint the clock
  Size size;
  // The following represent a percent of screen dimensions
  double topMargin = 0.05;
  double hourHeight = 0.20;
  double lineHeight = 0.20;
  double minuteHeight = 0.15;
  double line2Height = 0.15;
  double secondHeight = 0.05;
  double bottomMargin = 0.01;
  double leftMargin = 0.01;
  double blockWidth = 0.75;
  double numberWidth = 0.25;
  double rightMargin = 0.01;
  // The following are sizes in logical pixels
  double blockMargin = 2.0;
  double lineMarginMajor = 10.0;
  double lineMarginMinor = 25.0;
  double lineWidthMajor = 8.0;
  double lineWidthMinor = 4.0;
  // The following are ratios relative to block heights
  double hourFontSize = 1.5;
  double minuteFontSize = 1.5;
  double secondFontSize = 3.0;
  double dayFontSize = 1.5;
  // The following are the colors used for dark theme...
  Color fillColor = Colors.red;
  Color emptyColor = Colors.white24;
  Color lineColor = Colors.green;
  Color textColor = Colors.yellow;
  Color backColor = Colors.black;
  Brightness bright = Brightness.dark;

  // On initialization, the values above are updated based on the screen size
  BlockConfig(this.size, this.fillColor, this.bright) {
    topMargin *= size.height;
    hourHeight *= size.height;
    lineHeight *= size.height;
    minuteHeight *= size.height;
    line2Height *= size.height;
    secondHeight *= size.height;
    bottomMargin *= size.height;
    leftMargin *= size.width;
    blockWidth *= size.width;
    numberWidth *= size.width;
    rightMargin *= size.width;
    hourFontSize *= hourHeight;
    minuteFontSize *= minuteHeight;
    secondFontSize *= secondHeight;
    dayFontSize *= secondHeight;
    // reference device has height of 600 - scale pixel values up/down for this device size
    double scale = size.height / 600;
    blockMargin *= scale;
    lineMarginMajor *= scale;
    lineMarginMinor *= scale;
    lineWidthMajor *= scale;
    lineWidthMinor *= scale;
    // change colors on light mode
    if (bright == Brightness.light) {
      emptyColor = Colors.grey[500];
      lineColor = Colors.limeAccent[700];
      textColor = Colors.deepOrange[900];
      backColor = Colors.grey[400];
    }
  }
}
