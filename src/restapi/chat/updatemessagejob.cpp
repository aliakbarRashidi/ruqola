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

#include "updatemessagejob.h"
#include "ruqola_restapi_debug.h"
#include "restapimethod.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

UpdateMessageJob::UpdateMessageJob(QObject *parent)
    : RestApiAbstractJob(parent)
{
}

UpdateMessageJob::~UpdateMessageJob()
{
}

bool UpdateMessageJob::start()
{
    if (!canStart()) {
        deleteLater();
        return false;
    }
    const QByteArray baPostData = json().toJson(QJsonDocument::Compact);
    addLoggerInfo("UpdateMessageJob::start: " + baPostData);
    QNetworkReply *reply = mNetworkAccessManager->post(request(), baPostData);
    connect(reply, &QNetworkReply::finished, this, &UpdateMessageJob::slotUpdateMessageFinished);
    return true;
}

void UpdateMessageJob::slotUpdateMessageFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply) {
        const QByteArray data = reply->readAll();
        const QJsonDocument replyJson = QJsonDocument::fromJson(data);
        const QJsonObject replyObject = replyJson.object();

        if (replyObject[QStringLiteral("success")].toBool()) {
            qCDebug(RUQOLA_RESTAPI_LOG) << "Update Message success" << data;
            Q_EMIT updateMessageDone();
        } else {
            qCWarning(RUQOLA_RESTAPI_LOG) <<" Problem when we tried to update message" << data;
        }
    }
    deleteLater();
}

QString UpdateMessageJob::updatedText() const
{
    return mUpdatedText;
}

void UpdateMessageJob::setUpdatedText(const QString &updatedText)
{
    mUpdatedText = updatedText;
}

bool UpdateMessageJob::requireHttpAuthentication() const
{
    return true;
}

bool UpdateMessageJob::canStart() const
{
    if (mRoomId.isEmpty()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "UpdateMessageJob: roomId is empty";
        return false;
    }
    if (mMessageId.isEmpty()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "UpdateMessageJob: messageId is empty";
        return false;
    }
    //Updated text I think can be empty.

    if (!RestApiAbstractJob::canStart()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "Impossible to start UpdateMessageJob job";
        return false;
    }
    return true;
}

QJsonDocument UpdateMessageJob::json() const
{
    QJsonObject jsonObj;
    jsonObj[QLatin1String("roomId")] = mRoomId;
    jsonObj[QLatin1String("msgId")] = mMessageId;
    jsonObj[QLatin1String("text")] = mUpdatedText;

    const QJsonDocument postData = QJsonDocument(jsonObj);
    return postData;
}

QString UpdateMessageJob::roomId() const
{
    return mRoomId;
}

void UpdateMessageJob::setRoomId(const QString &roomId)
{
    mRoomId = roomId;
}

QString UpdateMessageJob::messageId() const
{
    return mMessageId;
}

void UpdateMessageJob::setMessageId(const QString &t)
{
    mMessageId = t;
}

QNetworkRequest UpdateMessageJob::request() const
{
    const QUrl url = mRestApiMethod->generateUrl(RestApiUtil::RestApiUrlType::ChatUpdate);
    QNetworkRequest request(url);
    addAuthRawHeader(request);
    request.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
    request.setAttribute(QNetworkRequest::HTTP2AllowedAttribute, true);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    return request;
}
