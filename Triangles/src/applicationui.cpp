/*
 * Copyright (c) 2011-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/device/DisplayInfo>
using namespace bb::cascades;
#include <QtSvg>
#include <QSvgRenderer>
#include "AppSettings.hpp"
#include <QDateTime>

#include <bb/cascades/InvokeQuery>
#include <bb/cascades/Invocation>

ApplicationUI::ApplicationUI() :
        QObject()
{
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this,
            SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);
    Q_UNUSED(res);

    onSystemLanguageChanged();
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("_app", this);
    bb::device::DisplayInfo display;
    dwidth = display.pixelSize().width();
    dheight = display.pixelSize().height();

    QDeclarativePropertyMap* displayProperties = new QDeclarativePropertyMap;
    displayProperties->insert("width", QVariant(dwidth));
    displayProperties->insert("height", QVariant(dheight));

    qml->setContextProperty("DisplayInfo", displayProperties);

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    QString locale_string = QLocale().name();
    QString file_name = QString("Triangles_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

void ApplicationUI::setValue(QString field, QString input)
{
    AppSettings::saveValueFor(field, input);
}

QString ApplicationUI::getValue(QString input, QString def)
{
    QString result = AppSettings::getValueFor(input, def);
    return result;
}

QString ApplicationUI::readTextFile(QString filepath)
{
    QFile file(filepath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";
    QString c = "";
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        c.append(line).append("\r\n");
    }
    return c;
}

bool ApplicationUI::writeTextFile(QString filepath, QString filecontent)
{
    QFile textfile(filepath);
    if (textfile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&textfile);
        out << filecontent;
        textfile.close();
        return (true);
    } else {
        return (false);
    }

}

QString ApplicationUI::updateImage()
{
    QString svgfile("data/background.svg");
    QSvgRenderer svg(svgfile);
    QString destination("data/background.png");
    QImage image(dwidth, dheight, QImage::Format_ARGB32);
    QPainter painter(&image);
    svg.render(&painter);
    image.save(destination, "PNG");
    return ("file://" + QDir().homePath() + "/background.png");
}

QString ApplicationUI::saveToAlbum()
{
    QFile originalfile("data/background.png");
    QString dest(
            "/accounts/1000/shared/misc/"
                    + QDateTime().currentDateTime().toString("yyyymmddhhmmsszzz") + ".png");
    qDebug() << dest;
    if (originalfile.copy(dest)) {
        return dest;
    } else {
        return "";
    }
}

void ApplicationUI::shareFile(QString fileName)
{
    if (!fileName.startsWith("file://")) {
        fileName = fileName.prepend("file://");
    }

    invocation = Invocation::create(InvokeQuery::create().parent(this).uri(fileName));

    connect(invocation, SIGNAL(armed()), this, SLOT(onArmed()));
    connect(invocation, SIGNAL(finished()), invocation, SLOT(deleteLater()));

}

void ApplicationUI::onArmed()
{
    invocation->trigger("bb.action.SHARE");
}
