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
import 'dart:ui' as ui;

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'block_config.dart';

//============================================================================================

class BlockClock extends StatefulWidget {
  const BlockClock(this.model);
  final ClockModel model;
  @override
  BlockClockState createState() => BlockClockState();
}

class BlockClockState extends State<BlockClock>
    with SingleTickerProviderStateMixin {
  AnimationController _animation;
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _animation = AnimationController(
      duration: const Duration(
          seconds:
              600), // Time to fully rotate the block fill color in the painter (10 minutes)
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Brightness _bright = Theme.of(context).brightness;
    return BlockClockWidget(
        controller: _animation, model: widget.model, bright: _bright);
  }

  void _updateModel() {
    setState(() {});
  }
}

class BlockClockWidget extends AnimatedWidget {
  final ClockModel model;
  final Brightness bright;
  const BlockClockWidget(
      {Key key, AnimationController controller, this.model, this.bright})
      : super(key: key, listenable: controller);
  Animation<double> get seconds => listenable;

  @override
  Widget build(BuildContext context) {
    Size size = ui.window.physicalSize / ui.window.devicePixelRatio;
    return CustomPaint(
      size: size,
      isComplex: false,
      willChange: true,
      painter: BlockPainter(seconds.value, model, bright),
      child: Container(height: size.height, width: size.width),
    );
  }
}

// This CustomPainter and supporting functions will draw the entire UI
// Use the value from the AnimationController (hue) to rotate through the 360 degree color hue spectrum.
class BlockPainter extends CustomPainter {
  double hue;
  ClockModel model;
  Brightness bright;
  BlockPainter(this.hue, this.model, this.bright);
  @override
  void paint(Canvas c, Size size) {
    DateTime dateTime = DateTime.now();
    HSLColor h = HSLColor.fromColor(Colors.red);
    BlockConfig config = BlockConfig(
        size, h.withHue(hue * 360).toColor().withOpacity(1.0), bright);
    int hour = dateTime.hour;
    if (!model.is24HourFormat) {
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
    }
    c.drawColor(config.backColor, BlendMode.clear);
    c.drawColor(config.backColor, BlendMode.color);
    paintHourBlocks(c, config, hour, model);
    if (hour == 23) paintLastHour(c, config, dateTime.minute);
    paintMinuteBlocks(c, config, dateTime.minute);
    if (dateTime.minute == 59) paintLastMinute(c, config, dateTime.second);
    paintSecondsBar(c, config, (dateTime.second * 1000) + dateTime.millisecond);
    paintStrings(c, config, dateTime, model);
    paintLines(c, config);
  }

  @override
  bool shouldRepaint(BlockPainter oldDelegate) {
    return true;
  }
}

// Draw 12 blocks to represent the hour, either filled or greyed
paintHourBlocks(Canvas c, BlockConfig cfg, int hour, ClockModel model) {
  int h;
  model.is24HourFormat ? h = 24 : h = 12;
  double w = cfg.blockWidth / h;
  Paint p = Paint()..color = cfg.fillColor;
  for (int x = 0; x < h; x++) {
    if (x == hour) p.color = cfg.emptyColor;
    c.drawRect(
        Rect.fromLTRB(
            cfg.leftMargin + (w * x),
            cfg.topMargin,
            cfg.leftMargin + (w * (x + 1)) - cfg.blockMargin,
            cfg.topMargin + cfg.hourHeight),
        p);
  }
}

// Gradually fill in the last (24th) hour block as minute go from 0-60
paintLastHour(Canvas c, BlockConfig cfg, int minute) {
  double startW = cfg.blockWidth - cfg.blockWidth / 24;
  double left = cfg.leftMargin + startW;
  double top = cfg.topMargin;
  double w = cfg.blockWidth / (24*60);
  c.drawRect(
      Rect.fromLTRB(left, top, left + (w * minute) - cfg.blockMargin,
          top + cfg.hourHeight),
      Paint()..color = cfg.fillColor);
}

// Draw 60 blocks to represent the minute
paintMinuteBlocks(Canvas c, BlockConfig cfg, int minute) {
  double w = cfg.blockWidth / 60;
  double top = cfg.topMargin + cfg.hourHeight + cfg.lineHeight;
  Paint p = Paint()..color = cfg.fillColor;
  for (int x = 0; x < 60; x++) {
    if (x == minute) p.color = cfg.emptyColor;
    c.drawRect(
        Rect.fromLTRB(
            cfg.leftMargin + (w * x),
            top,
            cfg.leftMargin + (w * (x + 1)) - cfg.blockMargin,
            top + cfg.minuteHeight),
        p);
  }
}

// Gradually fill in the last (60th) minute block as seconds go from 0-60
paintLastMinute(Canvas c, BlockConfig cfg, int seconds) {
  double w = cfg.blockWidth / 3600;
  double startW = cfg.blockWidth - cfg.blockWidth / 60;
  double left = cfg.leftMargin + startW;
  double top = cfg.topMargin + cfg.hourHeight + cfg.lineHeight;
  c.drawRect(
      Rect.fromLTRB(left, top, left + (w * seconds) - cfg.blockMargin,
          top + cfg.minuteHeight),
      Paint()..color = cfg.fillColor);
}

// Draw the progessively advancing seconds bar
paintSecondsBar(Canvas c, BlockConfig cfg, int milliSeconds) {
  double w = cfg.blockWidth / 60000;
  double blockHeight = cfg.secondHeight;
  double top = cfg.topMargin +
      cfg.hourHeight +
      cfg.lineHeight +
      cfg.minuteHeight +
      cfg.line2Height;
  double left = cfg.leftMargin;
  c.drawRect(
      Rect.fromLTRB(left, top, left + (w * milliSeconds), top + blockHeight),
      Paint()..color = cfg.fillColor);
  c.drawRect(
      Rect.fromLTRB(left + (w * milliSeconds), top, left + (cfg.blockWidth),
          top + blockHeight),
      Paint()..color = cfg.emptyColor);
}

// Draw lines between the bars to mark each hour and 5 and 15 minute/second sections
paintLines(Canvas c, BlockConfig cfg) {
  double w = cfg.blockWidth;
  double lm = cfg.leftMargin;
  double h1 = cfg.topMargin + cfg.hourHeight;
  double h2 = h1 + cfg.lineHeight;
  double h3 = h2 + cfg.minuteHeight;
  double h4 = h3 + cfg.line2Height;
  Paint p = Paint()..color = cfg.lineColor;
  double m;
  for (int x = 1; x < 12; x++) {
    if (x == 3 || x == 6 || x == 9) {
      p.strokeWidth = cfg.lineWidthMajor;
      m = cfg.lineMarginMajor;
    } else {
      p.strokeWidth = cfg.lineWidthMinor;
      m = cfg.lineMarginMinor;
    }
    c.drawLine(Offset(lm + w / 12 * x - 1, h1 + m),
        Offset(lm + w / 12 * x - 1, h2 - m), p);
    c.drawLine(Offset(lm + w / 12 * x - 1, h3 + m),
        Offset(lm + w / 12 * x - 1, h4 - m), p);
  }
}

// Draw the text items for the time and date
paintStrings(Canvas c, BlockConfig cfg, DateTime dateTime, ClockModel model) {
  String text;
  List<String> weatherSymbol = [
    '\u{2601}',
    '\u{1f32b}',
    '\u{2614}',
    '\u{2744}',
    '\u{2600}',
    '\u{26c8}',
    '\u{1f32c}'
  ];
  double width = cfg.numberWidth - cfg.rightMargin;
  int hour = dateTime.hour;
  if (!model.is24HourFormat) {
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
  }
  text = '0' + hour.toString();
  paintText(c, cfg, text.substring(text.length - 2), cfg.hourFontSize,
      Offset(cfg.blockWidth, 0.0), width);
  text = '0' + dateTime.minute.toString();
  paintText(c, cfg, text.substring(text.length - 2), cfg.minuteFontSize,
      Offset(cfg.blockWidth, cfg.hourHeight + cfg.lineHeight), width);
  text = '0' + dateTime.second.toString();
  paintText(
      c,
      cfg,
      text.substring(text.length - 2),
      cfg.secondFontSize,
      Offset(cfg.blockWidth,
          cfg.hourHeight + cfg.lineHeight + cfg.minuteHeight + cfg.line2Height),
      width);
  if (!model.is24HourFormat) {
    dateTime.hour < 12 ? text = 'AM' : text = 'PM';
    paintText(
        c,
        cfg,
        text,
        cfg.dayFontSize,
        Offset(cfg.blockWidth,
            cfg.size.height - (cfg.dayFontSize + cfg.bottomMargin)),
        width);
  }
  text = model.location +
      '     ' +
      model.temperatureString +
      ' ' +
      weatherSymbol[model.weatherCondition.index] +
      '\n' +
      DateFormat("EEEE, MMMM d, y").format(dateTime);
  paintText(
      c,
      cfg,
      text,
      cfg.dayFontSize,
      Offset(cfg.leftMargin,
          cfg.size.height - (2.25 * cfg.dayFontSize + cfg.bottomMargin)),
      cfg.blockWidth,
      leftJustify: true);
}

// Put text on the canvas
paintText(Canvas c, BlockConfig cfg, String text, double fontSize,
    Offset location, double width,
    {leftJustify: false}) {
  ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textDirection: ui.TextDirection.ltr,
      textAlign: leftJustify ? ui.TextAlign.left : ui.TextAlign.right));
  pb.pushStyle(ui.TextStyle(
      color: cfg.textColor,
      fontSize: fontSize,
      background: Paint()..color = cfg.backColor));
  pb.addText(text);
  ui.Paragraph p = pb.build();
  p.layout(ui.ParagraphConstraints(width: width));
  c.drawParagraph(p, location);
}
//tmp edit
