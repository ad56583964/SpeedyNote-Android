#include <QApplication>
#include <QLabel>
#include <QVBoxLayout>
#include <QWidget>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QWidget window;
    window.setWindowTitle("Qt Android Demo");
    auto *layout = new QVBoxLayout(&window);
    layout->addWidget(new QLabel("Hello from Qt on Android!"));
    window.show();
    return app.exec();
}
