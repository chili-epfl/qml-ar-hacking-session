import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtMultimedia 5.0
import CVCamera 1.0
import Chilitags 1.0
import Qt3D 2.0
import Qt3D.Shapes 2.0

Window {
    visible: true
    width: camera.size.width
    height: camera.size.height
    maximumWidth: camera.size.width
    maximumHeight: camera.size.height

    //Set up physical camera
    CVCamera{
        id: camera
        device: 1
        size: "640x480"
    }

    //Set up detection
    Chilitags{
        id: chilitags
        sourceImage: camera.cvImage

        //We declare the detection of tag #0
        ChilitagsObject{
            id: robottag
            name: "tag_0"
            property matrix4x4 z_up_transform: transform.times(Qt.matrix4x4(
                1, 0, 0, 10,
                0,-1, 0, 10,
                0, 0,-1, 0,
                0, 0, 0, 1)
            )
            property vector3d center : z_up_transform.times(Qt.vector3d(0,0,0))
            property vector3d xAxis : z_up_transform.times(Qt.vector3d(1,0,0)).minus(center)
            property vector3d yAxis : z_up_transform.times(Qt.vector3d(0,1,0)).minus(center)
            property vector3d zAxis : z_up_transform.times(Qt.vector3d(0,0,1)).minus(center)
        }
    }

    //Set up visual output
    VideoOutput{
        source: camera

        //This item is necessary for drawing with Qt3D
        Viewport {
            id: threeDItems
            width: parent.width
            height: parent.height
            navigation: false //Disable turning the camera by clicking and dragging

            //Picking ray
            property vector3d pickray: Qt.vector3d(touchbox.touchx - width/2, touchbox.touchy - height/2, height/2/Math.tan(glcam.fieldOfView/2/180.0*Math.PI))

            //Picked point on the floor (floor is defined by the robot tag)
            property vector3d floorpick: pickray.times(robottag.center.minus(glcam.eye).dotProduct(robottag.zAxis)/pickray.dotProduct(robottag.zAxis)).plus(glcam.eye)

            //Picked point on the tag frame
            property vector3d planepick: Qt.vector3d(floorpick.minus(robottag.center).dotProduct(robottag.xAxis),floorpick.minus(robottag.center).dotProduct(robottag.yAxis),0)

            //Previously picked point
            property vector3d lastpick

            //Our default camera conforms to the Chilitags frame
            camera: Camera {
                id:         glcam
                eye:        Qt.vector3d(0, 0,0) //Camera position
                center:     Qt.vector3d(0, 0,1) //Camera looks towards this position
                upVector:   Qt.vector3d(0,-1,0) //Camera's up (+Y axis) is towards this position
                fieldOfView: 38                 //In degrees, this needs to be calibrated/measured
            }

            //Our default light is from the camera towards the scene, might not be accurate for true AR scenes
            light: Light{
                position:  Qt.vector3d(0,0,0)
                direction: Qt.vector3d(0,0,-1) //There's something wrong here, this should point towards +Z, but doesn't work like that
            }

            //Area that we use to detect user touches
            MouseArea{
                id: touchbox

                property int touchx: 0
                property int touchy: 0

                anchors.fill: parent

                onPressed: {
                    if(!followTraj.running){
                        touchx = mouse.x;
                        touchy = mouse.y;
                        traj.clear();
                        traj.start(parent.planepick);
                        parent.lastpick = parent.planepick;
                    }
                }

                onPositionChanged: {
                    if(!followTraj.running){
                        touchx = mouse.x;
                        touchy = mouse.y;
                        if(parent.lastpick.minus(parent.planepick).length() > 10){
                            traj.addSegment(parent.planepick);
                            parent.lastpick = parent.planepick;
                        }
                    }
                }

                onReleased: {
                    if(!followTraj.running){
                        touchx = mouse.x;
                        touchy = mouse.y;
                        if(parent.lastpick.minus(parent.planepick).length() > 10){
                            traj.addSegment(parent.planepick);
                            parent.lastpick = parent.planepick;
                        }
                        traj.center();
                    }
                }
            }

            Trajectory{
                id: traj
                transform: [ MatrixTransform3D{ matrix: robottag.z_up_transform } ]
            }

            //Draw our 3D model
            Item3D{
                id: thymio
                mesh: Mesh{ source: "/assets/models/thymio/thymio.dae" }
                scale: 2.0/3.0
                transform: [
                    MatrixTransform3D{ matrix: followTraj.running ? traj.pose : Qt.matrix4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1) },
                    MatrixTransform3D{ matrix: robottag.z_up_transform }
                ]
                visible: robottag.visible
            }

            //Trajectory following mechanism
            SequentialAnimation{
                id: followTraj
                running: false

                NumberAnimation{
                    target: traj
                    property: "rate"
                    to: 1.0
                    duration: traj.totalLength * 10
                }

                NumberAnimation{
                    target: traj
                    property: "rate"
                    to: 0.0
                    duration: 0
                }

                onStopped: running = false
            }
        }
    }

    Button {
        id: startButton
        text: "Go!"
        onClicked: followTraj.running = true
        style: ButtonStyle {
            label: Text {
                renderType: Text.NativeRendering
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20
                text: control.text
            }
        }
    }
}

