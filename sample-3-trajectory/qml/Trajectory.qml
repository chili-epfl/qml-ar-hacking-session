import QtQuick 2.2
import Qt3D 2.0
import Qt3D.Shapes 2.0

Item3D{
    id: traj

    property var segmentQml: Qt.createComponent("LineSegment.qml")
    property var defaultColor: Effect{ color: "#77FFFF" }
    property vector3d begin: Qt.vector3d(0,0,0)
    property vector3d end: Qt.vector3d(0,0,0)
    property var segments: Array()
    property real totalLength: 0

    property real rate: 0
    property matrix4x4 pose: getPose(rate)

    property real beginx: begin.x
    property real beginy: begin.y
    property real beginz: begin.z

    property real endx: end.x
    property real endy: end.y
    property real endz: end.z

    /**
     * Starts recording a new trajectory
     */
    function start(begin_){
        begin = begin_;
        end = begin_;
    }

    /**
     * Adds a new segment to the trajectory
     */
    function addSegment(nextVertex){
        var newSeg = segmentQml.createObject(traj,{
            "id": "segment" + segments.length,
            "begin": end,
            "end": nextVertex,
            "thickness": 2 ,
            "effect" : defaultColor
        });
        end = nextVertex;
        segments.push(newSeg);
        totalLength += newSeg.length;
    }

    /**
     * Clears the trajectory segments
     */
    function clear(){
        while(segments.length > 0){
            segments.pop().destroy();
        }
        totalLength = 0;
    }

    /**
     * Brings the trajectory's beginning to the origin
     */
    function center(){
        if(segments.length == 0){
            return;
        }
        for(var i=0;i<segments.length;i++){
            segments[i].begin = segments[i].begin.minus(begin);
            segments[i].end = segments[i].end.minus(begin);
        }
        end = end.minus(begin);
        begin = Qt.vector3d(0,0,0);
    }

    /**
     * Returns the pose in the trajectory corresponding to the rate between [0,1]
     * where 0 is the beginning and 1 is the end of the trajectory
     */
    function getPose(rate){
        var targetLength = rate*totalLength;
        var currentLength = 0;

        //We can do better than linear search here
        for(var i=0;i<segments.length;i++){
            if(currentLength + segments[i].length >= targetLength){
                var intrate = (targetLength - currentLength)/segments[i].length;
                var pos = segments[i].begin.times(1 - intrate).plus(segments[i].end.times(intrate));
                var zAngle = -Math.PI/2 + Math.atan2((segments[i].end.y - segments[i].begin.y),(segments[i].end.x - segments[i].begin.x));
                var c = Math.cos(zAngle);
                var s = Math.sin(zAngle);
                return Qt.matrix4x4(
                    c, -s, 0, pos.x,
                    s,  c, 0, pos.y,
                    0,  0, 1, pos.z,
                    0,  0, 0, 1
                );
            }
            currentLength += segments[i].length;
        }

        return Qt.matrix4x4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        );
    }
}

