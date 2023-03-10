//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Copyright (c) 2022 Michael Ellis
//
//  Derived from colornotes.qml which is Copyright (c):
//      2012 Werner Schweer
//      2013-2017 Nicolas Froment, Joachim Schmitz
//      2014 Jörn Eichler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
      version: "3.5"
      description: qsTr("Colors notes in the selection that are sharped (red), double-sharped (pink), flatted (blue) or double-flatted (green). ")
      title:"Color Altered Notes";
      categoryCode: "color-notes";
      thumbnailName: "altercolor.png";

      // Define the colors we'll use for various alterations in rrggbb format.
      property string natural     : "#000000" // black
      property string doublesharp : "#ff00ff" // hot pink
      property string sharp       : "#ff0000" // red
      property string flat        : "#0080ff" // blue
      property string doubleflat  : "#00a000" // green

      // applyToNotesInSelection is a general purpose function that applies a
      // function to every note in the current selection or to all notes in the
      // score if there is no selection.  In this plugin, we use it to apply the
      // colorNotes function (defined in this file).
      function applyToNotesInSelection(func) {
            var fullScore = !curScore.selection.elements.length
            if (fullScore) {
                  cmd("select-all")
                  curScore.startCmd()
            }
            for (var i in curScore.selection.elements)
                  if (curScore.selection.elements[i].pitch)
                        func(curScore.selection.elements[i])
            if (fullScore) {
                  curScore.endCmd()
                  cmd("escape")
            }
      }

      // Musescore defines Tonal Pitch Class integers we can use to distinguish
      // altered pitches.  The numbers are conveniently arranged in sequences of
      // consecutive integers grouped by the number of semitones relative to the
      // natural pitch.
      // Here are the values from  https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/tpc.html

      // -1	F♭♭	6	F♭	13	F	20	F♯	27	F♯♯
      // 0	C♭♭	7	C♭	14	C	21	C♯	28	C♯♯
      // 1	G♭♭	8	G♭	15	G	22	G♯	29	G♯♯
      // 2	D♭♭	9	D♭	16	D	23	D♯	30	D♯♯
      // 3	A♭♭	10	A♭	17	A	24	A♯	31	A♯♯
      // 4	E♭♭	11	E♭	18	E	25	E♯	32	E♯♯
      // 5	B♭♭	12	B♭	19	B	26	B♯	33	B♯♯

      function colorAlteredNote(note) {
          // pick a color based on the tpc value
          var altercolor
          var n = note.tpc
          // console.log("note.tpc is " + n)
          if (n<7)
                altercolor = doubleflat;
          else if (n<13)
                altercolor = flat;
          else if (n<20)
                altercolor = natural;
          else if (n<27)
                altercolor = sharp;
          else if (n<34)
                 altercolor = doublesharp;
          else {
                 console.log("ignoring unknown tonal pitch class: " + note.tpc);
                 return
          } 

          // set the note color (or revert it)
          if (note.color == natural)
                note.color = altercolor;
          else
                note.color = natural;

          // color the accidental, if any
          if (note.accidental) {
              if (note.accidental.color == natural)
                    note.accidental.color = altercolor;
              else
                    note.accidental.color = natural;
          } 
          // color the dots, if any
          if (note.dots) {
              for (var i = 0; i < note.dots.length; i++) {
                  if (note.dots[i]) {
                      if (note.dots[i].color == natural)
                            note.dots[i].color = altercolor;
                      else
                            note.dots[i].color = natural;
                      }
               }
          }
      }
      // The onRun action for this plugin.
      onRun: {
            console.log("hello AlterColor");
            applyToNotesInSelection(colorAlteredNote)
      }
}
