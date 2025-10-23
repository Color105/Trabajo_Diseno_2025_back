# db/seeds.rb

# ------------------------------------
# 1. Limpieza de Datos
# ------------------------------------
puts "Limpiando base de datos..."
# ⚠️ CORRECCIÓN: Borrar en orden de dependencia inversa (hijos primero)
HistoricoEstado.destroy_all  # <-- Depende de Tramite y EstadoTramite
# AgendaConsultor.destroy_all # Descomentar si tienes esta tabla
Tramite.destroy_all          # <-- Depende de Consultor, TipoTramite, etc.

# Ahora borramos los "padres"
Consultor.destroy_all
TipoTramite.destroy_all
EstadoTramite.destroy_all    # <-- ¡Agregado!
puts "Base de datos limpia."

# ------------------------------------
# 2. Consultores (Carga Máxima Eliminada)
# ------------------------------------
puts "Creando Consultores..."
CONSULTORES_DATA = [
  { nombre: "Juan Perez",      email: "juan.perez@example.com" },
  { nombre: "María Gómez",     email: "maria.gomez@example.com" },
  { nombre: "Lucía Fernández", email: "lucia.fernandez@example.com" },
  { nombre: "Carlos López",    email: "carlos.lopez@example.com" },
  { nombre: "Santiago Ruiz",   email: "santiago.ruiz@example.com" }
]
CONSULTORES_DATA.map { |c| Consultor.find_or_create_by!(c) }
puts "✅ #{Consultor.count} Consultores creados."

# ------------------------------------
# 3. Tipos de Trámite
# ------------------------------------
puts "Creando Tipos de Trámite..."
TIPOS_DATA = [
  { nombre: "Visa de Trabajo",     plazo_documentacion: 30 },
  { nombre: "Residencia Temporal", plazo_documentacion: 20 },
  { nombre: "Revalidación Título", plazo_documentacion: 45 },
  { nombre: "Permiso de Conducir", plazo_documentacion: 15 }
]
TIPOS_DATA.map { |t| TipoTramite.find_or_create_by!(t) }
puts "✅ #{TipoTramite.count} Tipos de Trámite creados."

# ------------------------------------
# 4. Estados de Trámite (NUEVA SECCIÓN)
# ------------------------------------
puts "Creando Estados de Trámite..."
ESTADOS_DATA = [
  { codEstadoTramite: "ING", nombreEstadoTramite: "Ingresado" },
  { codEstadoTramite: "ASIG", nombreEstadoTramite: "Asignado" },
  { codEstadoTramite: "PROC", nombreEstadoTramite: "En Proceso" },
  { codEstadoTramite: "SUSP", nombreEstadoTramite: "Suspendido" },
  { codEstadoTramite: "TERM", nombreEstadoTramite: "Terminado" },
  { codEstadoTramite: "CANC", nombreEstadoTramite: "Cancelado" },
]
# Usamos find_or_create_by! para no duplicar si ya existen
ESTADOS_DATA.each { |e| EstadoTramite.find_or_create_by!(e) }
puts "✅ #{EstadoTramite.count} Estados de Trámite creados/verificados."


# ------------------------------------
# 5. Trámites de Ejemplo (Antes sección 4)
# ------------------------------------
puts "Creando Trámites de Ejemplo (LISTO)..."

# Recargamos los objetos desde la BD para asegurar que existan.
consultores = Consultor.all.to_a
tipos = TipoTramite.all.to_a
estados_map = EstadoTramite.all.index_by(&:nombreEstadoTramite)

# Asignaciones
juan, maria, lucia, carlos, santiago = consultores
visa, residencia, revalidacion, permiso = tipos

# Helper para generar códigos
gen_codigo = ->(seq) { "TR-%04d" % seq }

# --- ⚠️ CORRECCIÓN CLAVE AQUÍ ---
# Los 'estado:' deben coincidir con la lista VALID_STATES de tu modelo.
TRAMITES_DATA = [
  { 
    codigo: gen_codigo[1], estado: "ingresado", # <-- CORREGIDO
    fecha_inicio: 2.days.ago, monto: 1000, 
    consultor: juan, tipo_tramite: visa 
  },
  { 
    codigo: gen_codigo[2], estado: "asignado", # <-- CORREGIDO
    fecha_inicio: 1.day.ago, monto: 1500, 
    consultor: maria, tipo_tramite: residencia 
  },
  { 
    codigo: gen_codigo[3], estado: "en_proceso", # <-- CORREGIDO
    fecha_inicio: 3.days.ago, monto: 2500, 
    consultor: lucia, tipo_tramite: visa 
  },
  { 
    codigo: gen_codigo[4], estado: "suspendido", # <-- CORREGIDO
    fecha_inicio: 5.days.ago, monto: 800, 
    consultor: juan, tipo_tramite: revalidacion 
  },
  { 
    codigo: gen_codigo[5], estado: "terminado", # <-- CORREGIDO
    fecha_inicio: 7.days.ago, monto: 1200, 
    consultor: maria, tipo_tramite: permiso 
  },
  { 
    codigo: gen_codigo[6], estado: "cancelado", # <-- CORREGIDO
    fecha_inicio: 9.days.ago, monto: 600, 
    consultor: carlos, tipo_tramite: residencia 
  }
]

# Usamos create! directamente para crear el registro
TRAMITES_DATA.each_with_index do |attrs, index|
  data_for_creation = attrs.except(:consultor, :tipo_tramite).merge(
    consultor_id: attrs[:consultor].id,
    tipo_tramite_id: attrs[:tipo_tramite].id
  )
  
  begin
    Tramite.create!(data_for_creation)
  rescue ActiveRecord::RecordInvalid => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Validación): #{e.message}"
    exit 
  rescue => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Final): #{e.message}"
    exit
  end
end

puts "✅ #{Tramite.count} Trámites de Ejemplo creados."
puts "------------------------------------"
puts "Resumen: Base de datos cargada. Reinicia Rails y prueba la API."
puts "------------------------------------"