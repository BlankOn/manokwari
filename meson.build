# Inspired by https://github.com/budgie-desktop/budgie-desktop/blob/master/meson.build

project(
    'manokwari',
    ['c', 'vala'],
    version: '1.0.0',
    license: [
        'GPL-2.0',
    ],
    default_options: [
        'c_std=c11',
    ],
)

am_cflags = [
    '-fstack-protector',
    '-pedantic',
    '-Wstrict-prototypes',
    '-Wundef',
    '-Werror-implicit-function-declaration',
    '-Wformat',
    '-Wformat-security',
    '-Werror=format-security',
    '-Wconversion',
    '-Wunused-variable',
    '-Wunreachable-code',
    '-Wall',
    '-W',
]

add_global_arguments(am_cflags, language: 'c')

gnome_minimum_version = '>= 3.0.8'

dep_glib = dependency('glib-2.0', version: '>= 2.12.0')
dep_gtk3 = dependency('gtk+-3.0', version: gnome_minimum_version)
dep_atk = dependency('atk', version: '>= 2.0.0')
dep_gee = dependency('gee-1.0', version: '>= 0.6.1')
dep_cairo = dependency('cairo', version: '>= 1.10.2')
dep_libgnomemenu = dependency('libgnome-menu-3.0', version: '>= 2.30.5')
dep_libwnck = dependency('libwnck-3.0', version: '>= 3.0.0')
dep_unique = dependency('unique-3.0', version: '>= 3.0.0')
dep_webkit = dependency('webkitgtk-3.0', version: '>= 1.3.0')
dep_x11 = dependency('x11', version: '>= 1.6.0')
dep_libnotify = dependency('libnotify', version: '>= 0.7.6')

# Create config.h
cdata = configuration_data()

# Inspired by https://github.com/GNOME/recipes/blob/master/meson.build
package_version = meson.project_version()
cdata.set_quoted('PACKAGE_VERSION', package_version)

# Make gettext work
cdata.set_quoted('GETTEXT_PACKAGE', meson.project_name())
add_global_arguments('-DGETTEXT_PACKAGE="manokwari"', language: 'c')

# Globals that we need
prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
libdir = join_paths(prefix, get_option('libdir'))
confdir = join_paths(prefix, get_option('sysconfdir'))
datadir = join_paths(prefix, get_option('datadir'))
localedir = join_paths(prefix, get_option('localedir'))
podir = join_paths(meson.source_root(), 'po')

manokwari_system_path = join_paths(libdir, 'manokwari', 'system')
manokwari_session_path = join_paths(datadir, 'gnome-session', 'sessions')
manokwari_xsession_path = join_paths(datadir, 'xsessions')


# Handle i18n on the .desktop file
# Originally stolem from TingPing:
# https://github.com/vinszent/gnome-twitch/blob/master/data/meson.build
# Later changed to use intltool as we use _Key style files
intltool = find_program('intltool-merge')

cdata.set_quoted('SYSTEM_PATH', manokwari_system_path)
cdata.set_quoted('SESSIONS_PATH', manokwari_session_path)
cdata.set_quoted('XSESSIONS_PATH', manokwari_xsession_path)
cdata.set_quoted('BIN_PATH', bindir)
cdata.set_quoted('LOCALEDIR', localedir)


# Write config.h
configure_file(
    output: 'config.h',
    configuration: cdata,
)

extra_includes = [
    include_directories('.'),
]

subdir('po')
subdir('src')
subdir('system')
subdir('data')
subdir('files')
