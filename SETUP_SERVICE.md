## 📋 Instrucciones para crear el servicio Windows

El despliegue está listo. Usa estos scripts para completar la configuración del servicio.

---

## ✅ PASO 1: Crear el servicio de Windows

**Requisito:** PowerShell como Administrador

1. Abre PowerShell **como Administrador** (clic derecho → "Run as administrator")
2. Navega a la carpeta del proyecto:
   ```powershell
   Set-Location C:\Developer\free-claude-code
   ```

3. Ejecuta el script de configuración del servicio:
   ```powershell
   .\setup_service.ps1
   ```

   Este script:
   - Descarga automáticamente `nssm` (Non-Sucking Service Manager)
   - Crea un servicio Windows llamado `FreeClaudeCode`
   - Configura inicio automático
   - Inicia el servicio

   **Resultado esperado:**
   ```
   ✓ Service created and started successfully!
   Service is running. Access the application at:
     Local:  http://127.0.0.1:8082/admin
     Remote: http://<host-ip>:8082/admin
   ```

---

## ✅ PASO 2: Configurar la regla de Firewall (opcional, solo si necesitas acceso remoto)

**Requisito:** PowerShell como Administrador

1. En la misma PowerShell elevada, ejecuta:
   ```powershell
   .\setup_firewall.ps1
   ```

   Este script:
   - Crea una regla de firewall inbound en puerto 8082
   - Permite acceso desde redes externas

   **Resultado esperado:**
   ```
   ✓ Firewall rule created successfully!
   The server on port 8082 is now accessible from remote machines.
   ```

---

## 📊 Verificar el estado del servicio

Desde PowerShell (elevada o no), verifica que el servicio esté corriendo:

```powershell
sc.exe query FreeClaudeCode
```

Deberías ver:
```
STATE              : 4  RUNNING
```

---

## 🔍 Ver logs del servicio

```powershell
Get-Content C:\Developer\free-claude-code\logs\service.log -Tail 20
```

---

## 🛑 Comandos útiles

Detener el servicio:
```powershell
sc.exe stop FreeClaudeCode
```

Iniciar el servicio:
```powershell
sc.exe start FreeClaudeCode
```

Ver estado:
```powershell
sc.exe query FreeClaudeCode
```

Eliminar el servicio (si necesitas):
```powershell
sc.exe delete FreeClaudeCode
```

---

## 🌐 Acceso desde otra máquina

Una vez que el servicio está corriendo, accede desde otra máquina en la red:

**IP local del host:** 192.168.1.24 (ajusta según tu red)

Desde otra máquina Windows:
```powershell
Invoke-WebRequest -Uri 'http://192.168.1.24:8082/admin' -UseBasicParsing
```

Desde Linux/macOS:
```bash
curl -I http://192.168.1.24:8082/admin
```

Desde navegador:
```
http://192.168.1.24:8082/admin
```

---

## ⚠️ Solución de problemas

**El script dice "This script must be run as Administrator":**
- Abre PowerShell como Administrador (clic derecho en el ícono)

**El servicio no inicia:**
- Verifica los logs: `Get-Content C:\Developer\free-claude-code\logs\service.log`
- Comprueba que `start_server.ps1` existe y es accesible

**No puedo acceder desde otra máquina:**
- Verifica que el firewall esté configurado: `.\setup_firewall.ps1`
- Comprueba la conectividad: `ping <host-ip>`
- Verifica el puerto: `netstat -ano | Select-String ':8082'`

---

## 📌 Resumen

| Paso | Comando | Requerimiento |
|------|---------|-----------------|
| 1 | `.\setup_service.ps1` | Admin |
| 2 | `.\setup_firewall.ps1` | Admin (solo para acceso remoto) |
| 3 | `sc.exe query FreeClaudeCode` | Verificación |

El servicio se inicia automáticamente después del login del usuario y permanece corriendo continuamente.
