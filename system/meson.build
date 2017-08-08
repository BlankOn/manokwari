manokwari_system_subdir = [
    'css',
    'fonts',
    'img',
    'js',
    'widget',
]

manokwari_system_files = [
    'desktop.html',
    'menu.html',
    'texture.jpg',
    'texture.xcf',
]

foreach sub_dir : manokwari_system_subdir
    install_subdir(
        sub_dir,
        install_dir: join_paths(libdir, meson.project_name(), 'system'),
    )
endforeach

install_data(
    manokwari_system_files,
    install_dir: join_paths(libdir, meson.project_name(), 'system'),
)
