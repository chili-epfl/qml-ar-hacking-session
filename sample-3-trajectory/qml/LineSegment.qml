import QtQuick 2.2
import Qt3D 2.0
import Qt3D.Shapes 2.0

Item3D{
    property vector3d begin : Qt.vector3d(0,0,0)
    property vector3d end : Qt.vector3d(0,0,1)
    property real length: begin.minus(end).length()
    property real thickness : 0.5
    property var effect : Effect{ color: "#FFFFFF" }

    Sphere{
        id: sphere
        position: parent.end
        radius: parent.thickness
        effect: parent.effect
    }
}
