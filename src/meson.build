manokwari_panel_sources = [
    'main.vala',
    'panel-abstract-window.vala',
    'panel-window.vala',
    'panel-menu-box.vala',
    'panel-menu-content.vala',
    'panel-tray.vala',
    'panel-scrollable-content.vala',
    'panel-animated-adjustment.vala',
    'panel-clock.vala',
    'panel-screen.vala',
    'utils.vala',
    'panel-hotkey.vala',
    'panel-menu-html.vala',
    'panel-desktop.vala',
    'panel-desktop-html.vala',
    'panel-calendar.vala',
    'animated-property.vala',
    'panel-shell.vala',
    'panel-socket.vala',
    'panel-xdg-properties.vala',
]

manokwari_panel_deps = [
    dep_glib,
    dep_gio_unix,
    dep_gdk_x11,
    dep_gtk3,
    dep_atk,
    dep_x11,
    dep_gee,
    dep_cairo,
    dep_libgnomemenu,
    dep_unique,
    dep_webkit,
    dep_libnotify,
    dep_libwnck,
]

libmanoext_src = [
    'helper.vala',
    'panel-desktop-data.vala',
    'panel-init-webext.vala',
    'panel-places.vala',
    'panel-session-manager.vala',
    'panel-user.vala',
    'xdg-data.vala',
]

libmanoext_deps = [
    dep_gtk3,
    dep_glib,
    dep_libgnomemenu,
    dep_webkitext,
]

manokwari_vapi = join_paths(meson.source_root(), 'vapi')

manoext = library(
    'manoext', libmanoext_src,
    include_directories: extra_includes,
    vala_args: [
        '--vapidir', manokwari_vapi,
        '--pkg', 'config',
        '--pkg', 'gio-unix-2.0',
        '--pkg', 'javascriptcore',
        '--library', 'webkit_webextension_02',
    ],
    c_args: [
        '-DGMENU_I_KNOW_THIS_IS_UNSTABLE',
    ],
    dependencies: libmanoext_deps,
    install: true,
    install_dir: manokwari_system_path,
)

executable(
    'manokwari', manokwari_panel_sources,
    dependencies: manokwari_panel_deps,
    include_directories: extra_includes,
    vala_args: [
        '--vapidir', manokwari_vapi,
        '--pkg', 'config',
        '--pkg', 'javascriptcore',
    ],
    c_args: [
        '-DGMENU_I_KNOW_THIS_IS_UNSTABLE',
        '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
    ],
    install: true,
)
