<?xml version="1.0"?>
<api version="1.0">
	<namespace name="Indicator">
		<function name="get_version" symbol="get_version">
			<return-type type="gchar*"/>
		</function>
		<function name="image_helper" symbol="indicator_image_helper">
			<return-type type="GtkImage*"/>
			<parameters>
				<parameter name="name" type="gchar*"/>
			</parameters>
		</function>
		<function name="image_helper_update" symbol="indicator_image_helper_update">
			<return-type type="void"/>
			<parameters>
				<parameter name="image" type="GtkImage*"/>
				<parameter name="name" type="gchar*"/>
			</parameters>
		</function>
		<callback name="get_type_t">
			<return-type type="GType"/>
		</callback>
		<callback name="get_version_t">
			<return-type type="gchar*"/>
		</callback>
		<struct name="IndicatorObjectEntry">
			<method name="activate" symbol="indicator_object_entry_activate">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
					<parameter name="timestamp" type="guint"/>
				</parameters>
			</method>
			<method name="close" symbol="indicator_object_entry_close">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
					<parameter name="timestamp" type="guint"/>
				</parameters>
			</method>
			<field name="label" type="GtkLabel*"/>
			<field name="image" type="GtkImage*"/>
			<field name="menu" type="GtkMenu*"/>
			<field name="accessible_desc" type="gchar*"/>
			<field name="reserved1" type="GCallback"/>
			<field name="reserved2" type="GCallback"/>
			<field name="reserved3" type="GCallback"/>
			<field name="reserved4" type="GCallback"/>
		</struct>
		<enum name="IndicatorScrollDirection">
			<member name="INDICATOR_OBJECT_SCROLL_UP" value="0"/>
			<member name="INDICATOR_OBJECT_SCROLL_DOWN" value="1"/>
			<member name="INDICATOR_OBJECT_SCROLL_LEFT" value="2"/>
			<member name="INDICATOR_OBJECT_SCROLL_RIGHT" value="3"/>
		</enum>
		<object name="IndicatorDesktopShortcuts" parent="GObject" type-name="IndicatorDesktopShortcuts" get-type="indicator_desktop_shortcuts_get_type">
			<method name="get_nicks" symbol="indicator_desktop_shortcuts_get_nicks">
				<return-type type="gchar**"/>
				<parameters>
					<parameter name="ids" type="IndicatorDesktopShortcuts*"/>
				</parameters>
			</method>
			<constructor name="new" symbol="indicator_desktop_shortcuts_new">
				<return-type type="IndicatorDesktopShortcuts*"/>
				<parameters>
					<parameter name="file" type="gchar*"/>
					<parameter name="identity" type="gchar*"/>
				</parameters>
			</constructor>
			<method name="nick_exec" symbol="indicator_desktop_shortcuts_nick_exec">
				<return-type type="gboolean"/>
				<parameters>
					<parameter name="ids" type="IndicatorDesktopShortcuts*"/>
					<parameter name="nick" type="gchar*"/>
				</parameters>
			</method>
			<method name="nick_get_name" symbol="indicator_desktop_shortcuts_nick_get_name">
				<return-type type="gchar*"/>
				<parameters>
					<parameter name="ids" type="IndicatorDesktopShortcuts*"/>
					<parameter name="nick" type="gchar*"/>
				</parameters>
			</method>
			<property name="desktop-file" type="char*" readable="0" writable="1" construct="0" construct-only="1"/>
			<property name="identity" type="char*" readable="1" writable="1" construct="0" construct-only="1"/>
		</object>
		<object name="IndicatorObject" parent="GObject" type-name="IndicatorObject" get-type="indicator_object_get_type">
			<method name="get_entries" symbol="indicator_object_get_entries">
				<return-type type="GList*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</method>
			<method name="get_location" symbol="indicator_object_get_location">
				<return-type type="guint"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
				</parameters>
			</method>
			<method name="get_show_now" symbol="indicator_object_get_show_now">
				<return-type type="guint"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
				</parameters>
			</method>
			<constructor name="new_from_file" symbol="indicator_object_new_from_file">
				<return-type type="IndicatorObject*"/>
				<parameters>
					<parameter name="file" type="gchar*"/>
				</parameters>
			</constructor>
			<signal name="accessible-desc-update" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
				</parameters>
			</signal>
			<signal name="entry-added" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
				</parameters>
			</signal>
			<signal name="entry-moved" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
					<parameter name="old_pos" type="guint"/>
					<parameter name="new_pos" type="guint"/>
				</parameters>
			</signal>
			<signal name="entry-removed" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
				</parameters>
			</signal>
			<signal name="menu-show" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
					<parameter name="timestamp" type="guint"/>
				</parameters>
			</signal>
			<signal name="scroll" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="delta" type="guint"/>
					<parameter name="direction" type="IndicatorScrollDirection"/>
				</parameters>
			</signal>
			<signal name="scroll-entry" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
					<parameter name="delta" type="guint"/>
					<parameter name="direction" type="IndicatorScrollDirection"/>
				</parameters>
			</signal>
			<signal name="show-now-changed" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="gpointer"/>
					<parameter name="show_now_state" type="gboolean"/>
				</parameters>
			</signal>
			<vfunc name="entry_activate">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
					<parameter name="timestamp" type="guint"/>
				</parameters>
			</vfunc>
			<vfunc name="entry_close">
				<return-type type="void"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
					<parameter name="timestamp" type="guint"/>
				</parameters>
			</vfunc>
			<vfunc name="get_accessible_desc">
				<return-type type="gchar*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_entries">
				<return-type type="GList*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_image">
				<return-type type="GtkImage*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_label">
				<return-type type="GtkLabel*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_location">
				<return-type type="guint"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_menu">
				<return-type type="GtkMenu*"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
				</parameters>
			</vfunc>
			<vfunc name="get_show_now">
				<return-type type="gboolean"/>
				<parameters>
					<parameter name="io" type="IndicatorObject*"/>
					<parameter name="entry" type="IndicatorObjectEntry*"/>
				</parameters>
			</vfunc>
			<vfunc name="reserved1">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="reserved2">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="reserved3">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="reserved4">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="reserved5">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="reserved6">
				<return-type type="void"/>
			</vfunc>
		</object>
		<object name="IndicatorService" parent="GObject" type-name="IndicatorService" get-type="indicator_service_get_type">
			<constructor name="new" symbol="indicator_service_new">
				<return-type type="IndicatorService*"/>
				<parameters>
					<parameter name="name" type="gchar*"/>
				</parameters>
			</constructor>
			<constructor name="new_version" symbol="indicator_service_new_version">
				<return-type type="IndicatorService*"/>
				<parameters>
					<parameter name="name" type="gchar*"/>
					<parameter name="version" type="guint"/>
				</parameters>
			</constructor>
			<property name="name" type="char*" readable="1" writable="1" construct="0" construct-only="0"/>
			<property name="version" type="guint" readable="1" writable="1" construct="0" construct-only="0"/>
			<signal name="shutdown" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="service" type="IndicatorService*"/>
				</parameters>
			</signal>
			<vfunc name="indicator_service_reserved1">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_reserved2">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_reserved3">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_reserved4">
				<return-type type="void"/>
			</vfunc>
		</object>
		<object name="IndicatorServiceManager" parent="GObject" type-name="IndicatorServiceManager" get-type="indicator_service_manager_get_type">
			<method name="connected" symbol="indicator_service_manager_connected">
				<return-type type="gboolean"/>
				<parameters>
					<parameter name="sm" type="IndicatorServiceManager*"/>
				</parameters>
			</method>
			<constructor name="new" symbol="indicator_service_manager_new">
				<return-type type="IndicatorServiceManager*"/>
				<parameters>
					<parameter name="dbus_name" type="gchar*"/>
				</parameters>
			</constructor>
			<constructor name="new_version" symbol="indicator_service_manager_new_version">
				<return-type type="IndicatorServiceManager*"/>
				<parameters>
					<parameter name="dbus_name" type="gchar*"/>
					<parameter name="version" type="guint"/>
				</parameters>
			</constructor>
			<method name="set_refresh" symbol="indicator_service_manager_set_refresh">
				<return-type type="void"/>
				<parameters>
					<parameter name="sm" type="IndicatorServiceManager*"/>
					<parameter name="time_in_ms" type="guint"/>
				</parameters>
			</method>
			<property name="name" type="char*" readable="1" writable="1" construct="0" construct-only="0"/>
			<property name="version" type="guint" readable="1" writable="1" construct="0" construct-only="0"/>
			<signal name="connection-change" when="LAST">
				<return-type type="void"/>
				<parameters>
					<parameter name="sm" type="IndicatorServiceManager*"/>
					<parameter name="connected" type="gboolean"/>
				</parameters>
			</signal>
			<vfunc name="indicator_service_manager_reserved1">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_manager_reserved2">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_manager_reserved3">
				<return-type type="void"/>
			</vfunc>
			<vfunc name="indicator_service_manager_reserved4">
				<return-type type="void"/>
			</vfunc>
		</object>
		<constant name="INDICATOR_GET_TYPE_S" type="char*" value="get_type"/>
		<constant name="INDICATOR_GET_VERSION_S" type="char*" value="get_version"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_ACCESSIBLE_DESC_UPDATE" type="char*" value="accessible-desc-update"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_ENTRY_ADDED" type="char*" value="entry-added"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_ENTRY_MOVED" type="char*" value="entry-moved"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_ENTRY_REMOVED" type="char*" value="entry-removed"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_MENU_SHOW" type="char*" value="menu-show"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_SCROLL" type="char*" value="scroll"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_SCROLL_ENTRY" type="char*" value="scroll-entry"/>
		<constant name="INDICATOR_OBJECT_SIGNAL_SHOW_NOW_CHANGED" type="char*" value="show-now-changed"/>
		<constant name="INDICATOR_SERVICE_MANAGER_SIGNAL_CONNECTION_CHANGE" type="char*" value="connection-change"/>
		<constant name="INDICATOR_SERVICE_SIGNAL_SHUTDOWN" type="char*" value="shutdown"/>
		<constant name="INDICATOR_SET_VERSION" type="int" value="0"/>
		<constant name="INDICATOR_VERSION" type="char*" value="0.3.0"/>
	</namespace>
</api>
