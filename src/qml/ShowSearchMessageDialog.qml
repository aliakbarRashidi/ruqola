/*
   Copyright (c) 2018 Montel Laurent <montel@kde.org>

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


import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Window 2.0
import QtQuick 2.9
import KDE.Ruqola.UsersForRoomFilterProxyModel 1.0
import org.kde.kirigami 2.1 as Kirigami

QQC2.Dialog {
    id: showSearchMessageDialog

    title: i18n("Search Message")

    signal searchMessage(string pattern, string rid)

    property QtObject searchMessageModel
    property string roomId
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    modal: true

    standardButtons: QQC2.Dialog.Close

    function initializeAndOpen()
    {
        searchField.text = "";
        open();
    }

    ColumnLayout {
        QQC2.TextField {
            id: searchField
            focus: true
            selectByMouse: true
            Layout.minimumHeight: Layout.maximumHeight
            Layout.maximumHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
            Layout.fillWidth: true
            placeholderText: i18n("Search Word...")
            //onAccepted: or onTextChanged:  ????
            onAccepted: {
                showSearchMessageDialog.searchMessage(text, roomId)
            }
        }

        ListView {
            id: listview
            width: 400;
            height: 200
            clip: true
            // Scrollars
            QQC2.ScrollIndicator.vertical: QQC2.ScrollIndicator { }
            QQC2.ScrollIndicator.horizontal: QQC2.ScrollIndicator { }

            model: searchMessageModel
            delegate: Kirigami.BasicListItem {
                label: messagetext
                reserveSpaceForIcon: false
            }
        }
    }
}
