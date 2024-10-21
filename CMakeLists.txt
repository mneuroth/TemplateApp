# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(contactlist LANGUAGES CXX)


find_package(Qt6 REQUIRED COMPONENTS Core Widgets Gui Quick Svg Sensors)

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(templateapp WIN32 MACOSX_BUNDLE
    contactmodel.cpp contactmodel.h
    applicationdata.cpp applicationdata.h
    main.cpp
)

if(ANDROID)
    set_property(TARGET templateapp PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
        ${CMAKE_CURRENT_SOURCE_DIR}/android)
endif()

qt_add_qml_module(templateapp
    URI contactlist
    QML_FILES
        "ContactDelegate.ui.qml"
        "ContactDialog.qml"
        "ContactForm.ui.qml"
        "ContactView.ui.qml"
        "SectionDelegate.ui.qml"
        "ContactList.qml"
        "AboutDialog.qml"
        "AboutDialogForm.ui.qml"
        "SettingsDialog.qml"
        "SettingsDialogForm.ui.qml"
        "HomeForm.ui.qml"
        "Page1Form.ui.qml"
        "Page2Form.ui.qml"
        "MobileFileDialog.qml"
        "MobileFileDialogForm.ui.qml"
        "designer/Backend/ContactModel.qml"
    RESOURCES
        "pico_qt_logo.png"
        "images/menu_bars.svg"
        "images/menu.svg"
        "images/back.svg"
        "images/back-arrow.svg"
        "images/close.svg"
        "images/edit.svg"
        "images/floppy-disk.svg"
        "images/folder-black-24dp.svg"
        "images/left-arrow.svg"
        "images/new104.svg"
        "images/open-folder-with-document.svg"
        "images/redo-arrow.svg"
        "images/replace.svg"
        "images/right-arrow.svg"
        "images/search.svg"
        "images/settings.svg"
        "images/share.svg"
        "images/text_snippet-black-24dp.svg"
)

target_link_libraries(templateapp PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::Svg
    Qt6::Sensors
)

install(TARGETS templateapp
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET templateapp
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})
