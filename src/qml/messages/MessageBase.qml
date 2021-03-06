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

import QtQuick.Layouts 1.1
ColumnLayout {
    signal linkActivated(string link)
    signal jitsiCallConfActivated()
    signal deleteMessage(string messageId)
    signal copyMessage(string messageId, string messageStr)
    signal editMessage(string messageId, string messageStr)
    signal replyMessage(string messageId)
    signal setFavoriteMessage(string messageId, bool starred)
    signal downloadAttachment(string url)
    signal displayImage(url imageUrl, string title, bool isAnimatedImage)

    property string i_date
    property string i_username
    property string i_usernameurl
    property string i_aliasname
    property string i_avatar
    property var i_timestamp
    property string i_messageText
    property string i_originalMessage
    property var i_urls
    property var i_attachments
    property string i_editedByUserName
    property bool i_starred
    property bool i_can_editing_message



    property QtObject rcAccount

    NewDateLabel {
        id: newDateRect
        date: i_date
    }
}
