import flet as ft

def main(page: ft.Page):
    page.title = "NFC Ignite"
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    # Aquí irán los controles de la pantalla de login
    
    def mostrar_consultas(e):  # <-- Nueva función para mostrar la pantalla de consultas
        page.clean()
        page.add(
            ft.AppBar(
                title=ft.Text("Sistema de Inventario NFC Ignite"),
                actions=[
                    ft.IconButton(ft.icons.HOME, tooltip="Inicio", on_click=mostrar_menu),  # <-- Botón para volver al menú principal
                    ft.IconButton(ft.icons.SEARCH, tooltip="Consultar Inventario"),
                    ft.IconButton(ft.icons.EDIT, tooltip="Modificar Registros"),
                    ft.IconButton(ft.icons.BAR_CHART, tooltip="Estadísticas"),
                    ft.IconButton(ft.icons.EXIT_TO_APP, tooltip="Salir", on_click=logout)
                ]
            ),
            ft.Column(  # <-- Contenedor para las barras de búsqueda y la tabla
                [
                    ft.Row(  # <-- Fila para las barras de búsqueda
                        [
                            ft.TextField(hint_text="Buscar por ID", icon=ft.icons.SEARCH, width=300),
                            ft.TextField(hint_text="Buscar por nombre", icon=ft.icons.SEARCH, width=300),
                        ],
                        alignment=ft.MainAxisAlignment.SPACE_AROUND,  # <-- Distribuir el espacio entre las barras
                        vertical_alignment=ft.CrossAxisAlignment.START  # <-- Alinear las barras en la parte superior
                    ),
                ft.DataTable(
                    columns=[
                        ft.DataColumn(ft.Text("ID")),
                        ft.DataColumn(ft.Text("Nombre")),
                        ft.DataColumn(ft.Text("Descripción")),
                        ft.DataColumn(ft.Text("Cantidad")),
                    ],
                    rows=[
                        ft.DataRow(
                            cells=[
                                ft.DataCell(ft.Text("1")),
                                ft.DataCell(ft.Text("Producto A")),
                                ft.DataCell(ft.Text("Descripción del producto A")),
                                ft.DataCell(ft.Text("10")),
                            ]
                        ),
                    ]
                )
            ])
        )
        page.update()

    def mostrar_menu(e):
        page.clean()
        page.add(
            ft.AppBar(
                title=ft.Text("Sistema de Inventario NFC Ignite"),
                actions=[
                    ft.IconButton(ft.icons.HOME, tooltip="Inicio"),
                    ft.IconButton(ft.icons.SEARCH, tooltip="Consultar Inventario", on_click=mostrar_consultas),  # <-- Mostrar pantalla de consultas
                    ft.IconButton(ft.icons.EDIT, tooltip="Modificar Registros"),
                    ft.IconButton(ft.icons.BAR_CHART, tooltip="Estadísticas"),
                    ft.IconButton(ft.icons.EXIT_TO_APP, tooltip="Salir", on_click=logout)  # <-- Volver a la pantalla de login
                ]
            ),
            ft.Row(  # <-- Contenedor principal para centrar los botones
                [
                    ft.Column(  # <-- Columna para los botones
                        [
                            ft.ElevatedButton(icon=ft.icons.SEARCH, text="Consultar Inventario", width=200, on_click=mostrar_consultas),  # <-- Mostrar pantalla de consultas
                            ft.ElevatedButton(icon=ft.icons.EDIT, text="Modificar Registros", width=200),
                            ft.ElevatedButton(icon=ft.icons.BAR_CHART, text="Estadísticas", width=200),
                            ft.ElevatedButton(icon=ft.icons.INFO, text="Acerca de", width=200),
                            ft.ElevatedButton(icon=ft.icons.EXIT_TO_APP, text="Salir", width=200, on_click=logout)  # <-- Volver a la pantalla de login
                        ],
                        horizontal_alignment=ft.CrossAxisAlignment.CENTER  # <-- Centrar los botones horizontalmente
                    )
                ],
                alignment=ft.MainAxisAlignment.CENTER  # <-- Centrar la columna en la fila
            )
        )
        page.update()
        
    login_form = ft.Column(
            [
                ft.Image(src="assets/icon.png", width=200),
                ft.TextField(label="Usuario", width=300),
                ft.TextField(label="Contraseña", password=True, width=300),
                ft.ElevatedButton("Iniciar sesión", on_click=mostrar_menu)
            ]
        )
    page.add(login_form)
    
    def logout(e):
        page.clean()
        page.add(login_form)
        page.update()

    page.update()

ft.app(target=main, assets_dir="assets")