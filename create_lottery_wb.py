import openpyxl
from openpyxl.workbook import Workbook

def create_lottery_workbook(filename="analisis_loteria.xlsx"):
    wb = Workbook()
    ws = wb.active
    ws.title = "Analisis"

    # Encabezados
    headers = ["Numero", "Fecha", "Frecuencia Relativa", "Media Movil (3)", "Prediccion Basica"]
    ws.append(headers)

    # Datos de ejemplo (simulando historicos)
    # Rellenaremos con formulas para que sean dinamicas
    for i in range(2, 22):
        ws[f"A{i}"] = i * 2  # Simulación de números ganadores
        ws[f"B{i}"] = f"2026-06-{i:02d}"

    # Fórmulas dinámicas (Ejemplos matemáticos comunes en auditoría de lotería)

    # Frecuencia relativa: Suponiendo total de 100 sorteos en otra celda fija
    ws["G1"] = 100
    for i in range(2, 22):
        ws[f"C{i}"] = f"=A{i}/$G$1"

    # Media Móvil (3 periodos)
    for i in range(4, 22):
        ws[f"D{i}"] = f"=AVERAGE(A{i-2}:A{i})"

    # Predicción básica (Tendencia lineal simple)
    for i in range(2, 22):
        ws[f"E{i}"] = f"=A{i}*1.05"

    wb.save(filename)
    print(f"Libro de trabajo '{filename}' creado exitosamente con fórmulas dinámicas.")

if __name__ == "__main__":
    create_lottery_workbook()
