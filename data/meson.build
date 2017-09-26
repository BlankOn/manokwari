custom_target('desktop-file-applications',
    input : 'manokwari.desktop.in',
    output : 'manokwari.desktop',
    command : [intltool, '--desktop-style', podir, '@INPUT@', '@OUTPUT@'],
    install : true,
    install_dir : join_paths(datadir, 'applications'),
)
