import QtQuick
import Qt5Compat.GraphicalEffects

// A soft drop shadow under a rounded card, filling its parent's anchors like the card.
Item {
	id: root
	property real radius: 0
	property real blur: 24
	property real offsetY: 4
	property color color: Qt.alpha("black", 0.4)
	// Qt 6.8 compatibility: RectangularShadow requires Qt 6.9.
	RectangularGlow {
		anchors.fill: parent
		transform: Translate { y: root.offsetY }
		glowRadius: root.blur / 2
		cornerRadius: root.radius + glowRadius
		spread: 0.1
		color: root.color
	}
}
