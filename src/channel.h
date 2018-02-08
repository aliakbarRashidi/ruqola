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

#ifndef CHANNEL_H
#define CHANNEL_H

#include "libruqola_private_export.h"
#include "user.h"
#include <QObject>
#include <QDebug>

class LIBRUQOLACORE_TESTS_EXPORT Channel
{
    Q_GADGET
public:
    enum class ChannelType {
        Room,
        PrivateChannel,
        Unknown
    };
    Q_ENUM(ChannelType)

    Channel();
    ~Channel();
    void parseChannel(const QJsonObject &object);

    ChannelType type() const;
    void setType(const ChannelType &type);

    User user() const;
    void setUser(const User &user);

    bool operator==(const Channel &other) const;

    Channel &operator=(const Channel &other);


private:
    //TODO add room info.
    User mUser;
    ChannelType mType = ChannelType::Unknown;
};
Q_DECLARE_METATYPE(Channel)
Q_DECLARE_TYPEINFO(Channel, Q_MOVABLE_TYPE);
LIBRUQOLACORE_EXPORT QDebug operator <<(QDebug d, const Channel &t);

#endif // CHANNEL_H
