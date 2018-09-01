gnome_session_components = [
    'gnome-settings-daemon',
]

gnome_session_324_components = [
    'org.gnome.SettingsDaemon.A11ySettings',
    'org.gnome.SettingsDaemon.Clipboard',
    'org.gnome.SettingsDaemon.Color',
    'org.gnome.SettingsDaemon.Datetime',
    'org.gnome.SettingsDaemon.Housekeeping',
    'org.gnome.SettingsDaemon.Keyboard',
    'org.gnome.SettingsDaemon.MediaKeys',
    'org.gnome.SettingsDaemon.Mouse',
    'org.gnome.SettingsDaemon.Power',
    'org.gnome.SettingsDaemon.PrintNotifications',
    'org.gnome.SettingsDaemon.Rfkill',
    'org.gnome.SettingsDaemon.ScreensaverProxy',
    'org.gnome.SettingsDaemon.Sharing',
    'org.gnome.SettingsDaemon.Smartcard',
    'org.gnome.SettingsDaemon.Sound',
    'org.gnome.SettingsDaemon.Wacom',
    'org.gnome.SettingsDaemon.XSettings',
]

gsd_324_key = [
    'org.gnome.SettingsDaemon.A11yKeyboard'
]

gsd_324_max = [
    'org.gnome.SettingsDaemon.Orientation',
    'org.gnome.SettingsDaemon.XRANDR',
]

manokwari_components = [
    'mutter',
    'manokwari',
]

if dep_gsd.version().version_compare('>=3.27.90')
    session_components = manokwari_components + gnome_session_324_components
elif dep_gsd.version().version_compare('>=3.25.4')
    session_components = manokwari_components + gnome_session_324_components + gsd_324_key
elif dep_gsd.version().version_compare('>=3.23.3')
    session_components = manokwari_components + gnome_session_324_components + gsd_324_key + gsd_324_max
else
    session_components = gnome_session_components + manokwari_components
endif

session_data = configuration_data()
session_data.set('SESSION_COMPONENTS', ';'.join(session_components))

configure_file(
    input: 'blankon.session.in',
    output: 'blankon.session',
    configuration: session_data,
    install_dir: join_paths(get_option('datadir'), 'gnome-session', 'sessions'),
)