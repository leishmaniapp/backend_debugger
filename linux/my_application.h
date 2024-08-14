#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#define MY_APPLICATION_TITLE "Leishmaniapp Backend Debugger"
#define MY_APPLICATION_WIDTH 500
#define MY_APPLICATION_HEIGHT 800

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

#endif  // FLUTTER_MY_APPLICATION_H_
