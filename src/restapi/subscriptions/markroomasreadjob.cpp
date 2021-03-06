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

#include "markroomasreadjob.h"
#include "restapimethod.h"
#include "ruqola_restapi_debug.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

MarkRoomAsReadJob::MarkRoomAsReadJob(QObject *parent)
    : RestApiAbstractJob(parent)
{
}

MarkRoomAsReadJob::~MarkRoomAsReadJob()
{
}

bool MarkRoomAsReadJob::start()
{
    if (!canStart()) {
        deleteLater();
        return false;
    }
    const QByteArray baPostData = json().toJson(QJsonDocument::Compact);
    addLoggerInfo("MarkRoomAsReadJob::start: " + baPostData);
    QNetworkReply *reply = mNetworkAccessManager->post(request(), baPostData);
    connect(reply, &QNetworkReply::finished, this, &MarkRoomAsReadJob::slotMarkAsRead);
    addLoggerInfo(QByteArrayLiteral("MarkRoomAsReadJob: start"));
    return true;
}

void MarkRoomAsReadJob::slotMarkAsRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply) {
        const QByteArray data = reply->readAll();
        addLoggerInfo(QByteArrayLiteral("MarkRoomAsReadJob: finished: ") + data);
        Q_EMIT markAsReadDone();
    }
    deleteLater();
}

QString MarkRoomAsReadJob::roomId() const
{
    return mRoomId;
}

void MarkRoomAsReadJob::setRoomId(const QString &roomId)
{
    mRoomId = roomId;
}

bool MarkRoomAsReadJob::requireHttpAuthentication() const
{
    return true;
}

bool MarkRoomAsReadJob::canStart() const
{
    if (!RestApiAbstractJob::canStart()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "Impossible to start MarkRoomAsReadJob";
        return false;
    }
    if (mRoomId.isEmpty()) {
        qCWarning(RUQOLA_RESTAPI_LOG) << "MarkRoomAsReadJob: mRoomId is empty";
        return false;
    }
    return true;
}

QNetworkRequest MarkRoomAsReadJob::request() const
{
    const QUrl url = mRestApiMethod->generateUrl(RestApiUtil::RestApiUrlType::SubscriptionsRead);
    QNetworkRequest request(url);
    addAuthRawHeader(request);
    request.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
    request.setAttribute(QNetworkRequest::HTTP2AllowedAttribute, true);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    return request;
}

QJsonDocument MarkRoomAsReadJob::json() const
{
    QJsonObject jsonObj;
    jsonObj[QLatin1String("rid")] = mRoomId;

    const QJsonDocument postData = QJsonDocument(jsonObj);
    return postData;
}
