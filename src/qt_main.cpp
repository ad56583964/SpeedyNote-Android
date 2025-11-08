#include <QApplication>
#include <QLabel>
#include <QString>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QLabel label(QString::fromUtf8("Hello, Qt on Android (Debug)"));
    label.setMinimumSize(480, 320);
    label.setAlignment(Qt::AlignCenter);
    label.show();

    return app.exec();
}

