import flet as ft
import pyrebase
import matplotlib.pyplot as plt
import base64
from io import BytesIO

config = {
    "apiKey": "AIzaSyDIIQ73ZI2rJh1vOHeblrAZqkU2GHoFV50",
    "authDomain": "ignis-a2956.firebaseapp.com",
    "projectId": "ignis-a2956",
    "storageBucket": "ignis-a2956.firebasestorage.app",
    "messagingSenderId": "1089434384807",
    "appId": "1:1089434384807:web:9430756ba5eda03d731e82",
    "measurementId": "G-9N06YMYJ4X",
    "databaseURL": "https://ignis-a2956-default-rtdb.firebaseio.com/",
}

firebase = pyrebase.initialize_app(config)
auth = firebase.auth()


def main(page: ft.Page):
    page.title = "NC Ignite"
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
        
    def mostrar_estadisticas(e):
        # Acceder a la base de datos
        db = firebase.database()
        productos_ref = db.child("productos")
        productos = productos_ref.get().val()

        # Calcular estadísticas básicas
        total_productos = len(productos)
        total_cantidad = sum(producto["cantidad"] for producto in productos.values())

        # Agrupar productos por inventario
        productos_por_inventario = {}
        for producto in productos.values():
            inventario_id = producto["inventarioId"]
            if inventario_id not in productos_por_inventario:
                productos_por_inventario[inventario_id] = []
                productos_por_inventario[inventario_id].append(producto)

        # Crear datos para el gráfico de barras
        inventarios = list(productos_por_inventario.keys())
        cantidades = [sum(producto["cantidad"] for producto in productos)
                    for productos in productos_por_inventario.values()]

        # Crear el gráfico de barras con Plotly
        # Create the bar chart with Matplotlib
        plt.figure(figsize=(8, 6))  # Set figure size
        plt.bar(inventarios, cantidades)  # Create bars
        plt.xlabel('Inventario')  # Set x-axis label
        plt.ylabel('Cantidad')  # Set y-axis label
        plt.title('Productos por Inventario')  # Set chart title
        plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels for better readability

        # Convert the chart to a byte array
        buf = BytesIO()
        plt.savefig(buf, format='png')
        img_bytes = buf.getvalue()
        buf.close()
        plt.close()  # Close the figure to avoid memory leaks

        # Encode and display the image
        encoded = base64.b64encode(img_bytes).decode('utf-8')

        # Mostrar las estadísticas y el gráfico en la interfaz de Flet
        page.clean()
        page.add(
            ft.AppBar(
                title=ft.Text("Sistema de Inventario NFC Ignite"),
                actions=[
                    ft.IconButton(ft.icons.HOME, tooltip="Inicio", on_click=mostrar_menu),  # <-- Botón para volver al menú principal
                    ft.IconButton(ft.icons.SEARCH, tooltip="Consultar Inventario", on_click=mostrar_consultas),
                    ft.IconButton(ft.icons.BAR_CHART, tooltip="Estadísticas", on_click=mostrar_estadisticas),
                    ft.IconButton(ft.icons.EXIT_TO_APP, tooltip="Salir", on_click=logout)
                ]
            ),
            ft.Column([
                ft.Text(f"Total de productos: {total_productos}"),
                ft.Text(f"Cantidad total: {total_cantidad}"),
                ft.Image(src=f"data:image/png;base64,{encoded}")
            ])
        )
        page.update()


    def mostrar_consultas(e):  # <-- Nueva función para mostrar la pantalla de consultas
        db = firebase.database()

        # Get a reference to the 'productos' node
        productos_ref = db.child("productos")

        # Fetch all product data (can be optimized later)
        productos = productos_ref.get().val()

        # Prepare data for DataTable rows
        data_rows = []
        if productos:
            for producto_id, producto_data in productos.items():
                data_rows.append(
                    ft.DataRow(
                        cells=[
                            ft.DataCell(ft.Text(producto_data["id"])),
                            ft.DataCell(ft.Text(producto_data["nombre"])),
                            # Add a check for "descripcion" key if it exists
                            ft.DataCell(ft.Text(producto_data["inventarioId"])),
                            ft.DataCell(ft.Text(str(producto_data["cantidad"]))),
                        ]
                    )
                )

  # Update DataTable with fetched data
        page.clean()
        page.add(
            ft.AppBar(
                title=ft.Text("Sistema de Inventario NFC Ignite"),
                actions=[
                    ft.IconButton(ft.icons.HOME, tooltip="Inicio", on_click=mostrar_menu),  # <-- Botón para volver al menú principal
                    ft.IconButton(ft.icons.SEARCH, tooltip="Consultar Inventario", on_click=mostrar_consultas),
                    ft.IconButton(ft.icons.BAR_CHART, tooltip="Estadísticas", on_click=mostrar_estadisticas),
                    ft.IconButton(ft.icons.EXIT_TO_APP, tooltip="Salir", on_click=logout)
                ]
            ),
            ft.Column(  # <-- Contenedor para las barras de búsqueda y la tabla
                [
                    ft.TextField(hint_text="Buscar por ID", icon=ft.icons.SEARCH, width=300),
                    ft.TextField(hint_text="Buscar por nombre", icon=ft.icons.SEARCH, width=300),
                ft.DataTable(
                    columns=[
                        ft.DataColumn(ft.Text("ID")),
                        ft.DataColumn(ft.Text("Nombre")),
                        ft.DataColumn(ft.Text("Ubicación (Inventario ID)")),
                        ft.DataColumn(ft.Text("Cantidad")),
                    ],
                    rows=data_rows,
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
                    ft.IconButton(ft.icons.BAR_CHART, tooltip="Estadísticas", on_click=mostrar_estadisticas),  # <-- Mostrar pantalla de estadísticas
                    ft.IconButton(ft.icons.EXIT_TO_APP, tooltip="Salir", on_click=logout)  # <-- Volver a la pantalla de login
                ]
            ),
            ft.Row(  # <-- Contenedor principal para centrar los botones
                [
                    ft.Column(  # <-- Columna para los botones
                        [
                            ft.ElevatedButton(icon=ft.icons.SEARCH, text="Consultar Inventario", width=200, on_click=mostrar_consultas),  # <-- Mostrar pantalla de consultas
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