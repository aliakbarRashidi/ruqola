/*
   Copyright (c) 2017-2018 Montel Laurent <montel@kde.org>

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU Library General Public License as published
   by the Free Software Foundation; either version 2 of the License or
   ( at your option ) version 3 or, at the discretion of KDE e.V.
   ( which shall act as a proxy as in section 14 of the GPLv3 ), any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public License
   along with this library; see the file COPYING.LIB.  If not, write to
   the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.
*/

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Window 2.0
import KDE.Ruqola.DebugCategory 1.0
import KDE.Ruqola.RocketChatAccount 1.0
import KDE.Ruqola.RoomWrapper 1.0
import "common"
QQC2.Dialog {
    id: channelInfoDialog

    title: i18n("Info about this channel")
    standardButtons: QQC2.Dialog.Close

    modal: true
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    property string channelName: ""
    property QtObject roomInfo

    signal modifyChannelSetting(string roomId, int type, var newVal, string channelType)
    signal deleteRoom(string roomId)

    function initializeAndOpen()
    {
        var enabledField = !roomInfo.canBeModify;
        channelNameField.setReadOnly(enabledField);
        channelCommentField.setReadOnly(enabledField);
        channelAnnouncementField.setReadOnly(enabledField);
        channelDescriptionField.setReadOnly(enabledField);
        labelReadOnlyRoom.visible = !enabledField
        readOnlyRoom.visible = !enabledField
        labelArchiveRoom.visible = !enabledField
        archiveRoom.visible = !enabledField
        labelDeleteButton.visible = !enabledField
        deleteButton.visible = !enabledField
        labelRoomType.visible = !enabledField
        roomType.visible = !enabledField
        open();
    }

    GridLayout {
        columns: 2
        QQC2.Label {
            text: i18n("Name:");
        }
        TextFieldEditor {
            id: channelNameField
            textField: roomInfo === null ? "" : roomInfo.name

            onUpdateValue: {
                if (newVal != "") {
                    if (roomInfo.name !== newVal) {
                        channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.Name, newVal, roomInfo.channelType)
                    }
                } else {
                    //see https://doc.qt.io/qt-5/qml-qtqml-loggingcategory.html
                    console.log(RuqolaDebugCategorySingleton.category, "New name is empty. We can't rename room name to empty name.")
                }
            }
        }
        QQC2.Label {
            text: i18n("Comment:");
        }
        TextFieldEditor {
            id: channelCommentField
            textField: roomInfo === null ? "" : roomInfo.topic
            onUpdateValue: {
                if (roomInfo.topic !== newVal) {
                    channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.Topic, newVal, roomInfo.channelType)
                }
            }
        }
        QQC2.Label {
            text: i18n("Announcement:");
        }
        TextFieldEditor {
            id: channelAnnouncementField
            textField: roomInfo === null ? "" : roomInfo.announcement;
            onUpdateValue: {
                if (roomInfo.announcement !== newVal) {
                    channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.Announcement, newVal, roomInfo.channelType)
                }
            }
        }
        QQC2.Label {
            text: i18n("Description:");
        }
        TextFieldEditor {
            id: channelDescriptionField
            textField: roomInfo === null ? "" : roomInfo.description;
            onUpdateValue: {
                if (roomInfo.description !== newVal) {
                    channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.Description, newVal, roomInfo.channelType)
                }
            }
        }

        QQC2.Label {
            id: labelReadOnlyRoom
            text: i18n("Read-Only:");
        }
        QQC2.Switch {
            id: readOnlyRoom
            checked: roomInfo === null ? false : roomInfo.readOnly
            onClicked: {
                channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.ReadOnly, checked, roomInfo.channelType)
            }
        }

        QQC2.Label {
            id: labelArchiveRoom
            text: i18n("Archive:");
        }
        QQC2.Switch {
            id: archiveRoom
            checked: roomInfo === null ? false : roomInfo.archived
            onClicked: {
                archiveRoomDialog.open()
            }
        }

        QQC2.Label {
            id: labelRoomType
            text: i18n("Private:")
        }
        QQC2.Switch {
            id: roomType
            checked: roomInfo === null ? false : roomInfo.channelType === "p"
            onClicked: {
                channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.RoomType, checked, roomInfo.channelType)
            }
        }

        QQC2.Label {
            id: labelDeleteButton
            text: i18n("Delete Room:");
        }
        DeleteButton {
            id: deleteButton
            onDeleteButtonClicked: {
                deleteRoomDialog.rId = roomInfo.rid
                deleteRoomDialog.open();
            }
        }
    }

    ArchiveRoomDialog {
        id: archiveRoomDialog
        onAccepted: {
            channelInfoDialog.modifyChannelSetting(channelName, RocketChatAccount.Archive, true)
        }
        onRejected: {
            archiveRoom.checked = false
        }
    }

    DeleteRoomDialog {
        id: deleteRoomDialog
        rId: channelName
        onDeleteRoom: {
            channelInfoDialog.deleteRoom(roomId)
        }
    }
}
