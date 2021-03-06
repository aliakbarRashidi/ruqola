/*
 * Copyright 2016  Riccardo Iaconelli <riccardo@kde.org>
 * Copyright (C) 2017-2018 Laurent Montel <montel@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as QQC2
import KDE.Ruqola.RocketChatAccount 1.0
import KDE.Ruqola.Ruqola 1.0
import KDE.Ruqola.RoomFilterProxyModel 1.0
import KDE.Ruqola.UsersForRoomFilterProxyModel 1.0
import org.kde.kirigami 2.1 as Kirigami
import KDE.Ruqola.StatusModel 1.0

Component {
    id: roomsComponent
    Kirigami.ScrollablePage {
        id: roomsPage

        actions.main: Kirigami.Action {
            id: editAction
            iconName: "list-add"
            text: i18n("Open room");
            onTriggered: {
                searchChannelDialog.initializeAndOpen();
            }
        }
        actions.left: Kirigami.Action {
            iconName: "edit-symbolic"
            text: i18n("Edit room");
            checkable: true
            onToggled: {
                roomsList.editingMode = checked
                // do stuff
            }
        }
        background: Rectangle {
            color: Kirigami.Theme.viewBackgroundColor
        }

        header: Column {

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.leftMargin: 2*Kirigami.Units.smallSpacing
                    QQC2.Label {
                        id: comboboxLabel

                        text: i18n("Status:")
                    }

                    QQC2.ComboBox {
                        id: statusCombobox
                        Layout.alignment: Qt.AlignLeft
                        model: appid.rocketChatAccount.statusModel()
                        textRole: "statusi18n"
                        onActivated: {
                            appid.rocketChatAccount.changeDefaultStatus(index)
                        }
                        currentIndex: model.currentStatus

                        delegate: Kirigami.BasicListItem {
                            icon: model.icon

                            label: model.statusi18n
                        }
                    }
                }
                QQC2.TextField {
                    id: searchField
                    focus: true
                    Layout.minimumHeight: Layout.maximumHeight
                    Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
                    Layout.fillWidth: true
                    //width: parent.width
                    placeholderText: i18n("Search room...")
                    onTextChanged: {
                        appid.rocketChatAccount.roomFilterProxyModel().setFilterString(text);
                        //TODO filter list view
                    }
                }
            }
        }

        mainItem:
            RoomsView {
            id: roomsList
            implicitWidth: Kirigami.Units.gridUnit * 10
            anchors.fill: parent
            model: appid.rocketChatAccount.roomFilterProxyModel()
            selectedRoomID: appid.selectedRoomID;
            onHideRoom: {
                rocketChatAccount.hideRoom(roomID)
            }
            onLeaveRoom: {
                //TODO move to desktop.qml
                leaveChannelDialog.rId = roomID
                leaveChannelDialog.roomInfo = appid.selectedRoom
                leaveChannelDialog.open()
            }

            onRoomSelected: {
                if (roomID == selectedRoomID) {
                    return;
                }
                appid.rocketChatAccount.setUserCurrentMessage(appid.userInputMessageText, selectedRoomID)
                appid.selectedRoomID = roomID;
                appid.messageModel = appid.rocketChatAccount.messageModelForRoom(roomID)
                appid.selectedRoom = appid.rocketChatAccount.getRoomWrapper(roomID)
                appid.userModel = appid.rocketChatAccount.usersForRoomFilterProxyModel(roomID)
                appid.filesModel = appid.rocketChatAccount.filesForRoomFilterProxyModel(roomID)
            }
        } //RoomsView
    }
}
