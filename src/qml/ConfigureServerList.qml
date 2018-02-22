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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.1 as Kirigami
import KDE.Ruqola.RocketChatAccount 1.0

Kirigami.Page {
    id: configureServer

    implicitHeight: 400
    implicitWidth: 300

    property QtObject accountModel

    ListView {
        id: listview
        width: 300;
        height: 200

        model: accountModel
        delegate:
            RowLayout {
            Text {
                text: name
            }
            Kirigami.Icon {
                //Fix icon ??
                source: "list-remove"
                //FIXME
                height: 22
                width: 22
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //TODO show dialogbox when we remove account
                    }
                }
            }
        }
    }
}
