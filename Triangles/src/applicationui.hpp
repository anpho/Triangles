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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/cascades/InvokeQuery>
#include <bb/cascades/Invocation>
namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}

class QTranslator;

class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI();
    virtual ~ApplicationUI() {};
    Q_INVOKABLE QString readTextFile(QString filepath);
    Q_INVOKABLE bool writeTextFile(QString filepath, QString filecontent);
    Q_INVOKABLE QString getValue(QString input, QString def);
    Q_INVOKABLE void setValue(QString field, QString value);
    Q_INVOKABLE QString updateImage();
    Q_INVOKABLE QString saveToAlbum();
    Q_INVOKABLE void shareFile(QString fileName);

private slots:
    void onSystemLanguageChanged();
    void onArmed();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    int dwidth;
    int dheight;
    bb::cascades::Invocation* invocation;
};

#endif /* ApplicationUI_HPP_ */
