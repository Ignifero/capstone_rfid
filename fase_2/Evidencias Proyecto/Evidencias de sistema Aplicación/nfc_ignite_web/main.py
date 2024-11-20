import flet as ft
import pyrebase

config = {
    "apiKey": "AIzaSyDIIQ73ZI2rJh1vOHeblrAZqkU2GHoFV50",
    "authDomain": "ignis-a2956.firebaseapp.com",
    "projectId": "ignis-a2956",
    "storageBucket": "ignis-a2956.firebasestorage.app",
    "messagingSenderId": "1089434384807",
    "appId": "1:1089434384807:web:9430756ba5eda03d731e82",
    "measurementId": "G-9N06YMYJ4X",
    "databaseURL": "",
}

firebase = pyrebase.initialize_app(config)
auth = firebase.auth()


def main(page: ft.Page):
    page.title = "NFC Ignite"
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    username_field = ft.TextField(label="Usuario", width=300)
    password_field = ft.TextField(label="Contraseña", password=True, width=300)

    def login(e):
        email = username_field.value
        password = password_field.value
        try:
            auth.sign_in_with_email_and_password(email, password)
            mostrar_menu(e)  
        except Exception as error:
            print(f"Error logging in: {error}")
            page.snackbar = ft.SnackBar(ft.Text("Usuario o contraseña incorrectos"), duration=3000)
            page.snackbar.open = True
            page.add(page.snackbar)
            page.update()

    def logout(e):
        page.clean()
        page.add(login_form)
        page.update()


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
            username_field,
            password_field,
            ft.ElevatedButton("Iniciar sesión", on_click=login, width=300),
        ]
    )

    page.add(login_form)
    page.update()

ft.app(target=main, assets_dir="assets")