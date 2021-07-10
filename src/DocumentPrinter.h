/**
 * SPDX-FileCopyrightText: 2021 by Alexander Stippich <a.stippich@gmx.net>
 *  
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#ifndef DOCUMENTPRINTER_H
#define DOCUMENTPRINTER_H

#include <memory>

#include <QObject>
#include <QString>
#include <QFuture>

#include "SkanpageUtils.h"

class QPrinter;

class DocumentPrinter : public QObject
{
    Q_OBJECT

public:

    explicit DocumentPrinter(QObject *parent = nullptr);
    ~DocumentPrinter();
    
    void printDocument(const SkanpageUtils::DocumentPages &document);
    
Q_SIGNALS:
    void showUserMessage(SkanpageUtils::MessageLevel level, const QString &text);

private:
    void print(const SkanpageUtils::DocumentPages &document);

    std::unique_ptr<QPrinter> m_printer;
    QFuture<void> m_future;
};

#endif
