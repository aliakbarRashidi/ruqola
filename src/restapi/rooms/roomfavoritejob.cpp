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

#include "roomfavoritejob.h"
#include "restapimethod.h"
#include "ruqola_restapi_debug.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

RoomFavoriteJob::RoomFavoriteJob(QObject *parent)
    : RestApiAbstractJob(parent)
{
}

RoomFavoriteJob::~RoomFavoriteJob()
{
}

bool RoomFavoriteJob::start()
{
    if (!canStart()) {
        deleteLater();
        return false;
    }
    const QByteArray baPostData = json().toJson(QJsonDocument::Compact);
    addLoggerInfo("RoomFavoriteJob::start: " + baPostData);
    QNetworkReply *reply = mNetworkAccessManager->post(request(), baPostData);
    connect(reply, &QNetworkReply::finished, this, &RoomFavoriteJob::slotChangeFavoriteFinished);
    addLoggerInfo(QByteArrayLiteral("RoomFavoriteJob: start"));
    return true;
}

void RoomFavoriteJob::slotChangeFavoriteFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply) {
        const QByteArray data = reply->readAll();
        addLoggerInfo(QByteArrayLiteral("RoomFavoriteJob: finished: ") + data);
        const QJsonDocument replyJson = QJsonDocument::fromJson(data);
        const QJsonObject replyObject = replyJson.object();

        if (replyObject[QStringLiteral("success")].toBool()) {
            qCDebug(RUQOLA_RESTAPI_LOG) << "Change favorite status done: " << data;
            Q_EMIT changeFavoriteDone();
        } else {
            qCWarning(RUQOLA_RESTAPI_LOG) <<" Problem when we tried to change favorite status" << data;
        }
    }
    deleteLater();
}

bool RoomFavoriteJob::favorite() const
{
    return mFavorite;
}

void RoomFavoriteJob::setFavorite(bool favorite)
{
    mFavorite = favorite;
}

QString RoomFavoriteJob::roomId() const
{
    return mRoomId;
}

void RoomFavoriteJob::setRoomId(const QString &roomId)
{
    mRoomId = roomId;
}

bool RoomFavoriteJob::requireHttpAuthentication() const
{
    return true;
}

bool RoomFavoriteJob::canStart() const
{
    if (!RestApiAbstractJob::canStart()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "Impossible to start RoomFavoriteJob";
        return false;
    }
    if (mRoomId.isEmpty()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "RoomFavoriteJob: mRoomId is empty";
        return false;
    }
    return true;
}

QNetworkRequest RoomFavoriteJob::request() const
{
    const QUrl url = mRestApiMethod->generateUrl(RestApiUtil::RestApiUrlType::RoomsFavorite);
    QNetworkRequest request(url);
    addAuthRawHeader(request);
    request.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
    request.setAttribute(QNetworkRequest::HTTP2AllowedAttribute, true);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    return request;
}

QJsonDocument RoomFavoriteJob::json() const
{
    QJsonObject jsonObj;
    jsonObj[QLatin1String("roomId")] = mRoomId;
    jsonObj[QLatin1String("favorite")] = mFavorite;

    const QJsonDocument postData = QJsonDocument(jsonObj);
    return postData;
}
