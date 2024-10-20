// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "applicationdata.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName("mneuroth");
    QGuiApplication::setApplicationName("Contact List");

    QQmlApplicationEngine engine;

    ApplicationData data(0, 0, 0, engine);
    engine.rootContext()->setContextProperty("applicationData", &data);

    engine.loadFromModule("contactlist", "ContactList");
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
