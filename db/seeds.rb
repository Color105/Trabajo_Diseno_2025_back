# db/seeds.rb

# ------------------------------------
# 1. Limpieza de Datos
# ------------------------------------
puts "Limpiando base de datos..."
# ⚠️ CORRECCIÓN: Borrar en orden de dependencia inversa (hijos primero)
HistoricoEstado.destroy_all
# AgendaConsultor.destroy_all # Descomentar si tienes esta tabla
Tramite.destroy_all

# Ahora borramos los "padres"
Cliente.destroy_all          # <-- ¡Agregado!
User.destroy_all             # <-- ¡Agregado! (Maneja admin/cliente login)
Consultor.destroy_all
TipoTramite.destroy_all
EstadoTramite.destroy_all
puts "Base de datos limpia."

# ------------------------------------
# 1.b Usuarios (para login JWT)
# ------------------------------------
puts "Creando usuarios (admin / recepcionista)..."

User.find_or_create_by!(email: "admin@demo.com") do |u|
  u.name = "Admin"
  u.role = :admin
  u.password = "admin123"
  u.password_confirmation = "admin123"
end

User.find_or_create_by!(email: "recep@demo.com") do |u|
  u.name = "Recepcion"
  u.role = :recepcionista
  u.password = "recep123"
  u.password_confirmation = "recep123"
end

puts "✅ #{User.where(role: [:admin, :recepcionista]).count} usuarios de gestión creados."

# ------------------------------------
# 1.c ¡NUEVO! Clientes de prueba
# ------------------------------------
puts "--- Creando Clientes de prueba ---"

begin
  user_cliente_1 = User.find_or_create_by!(email: 'cliente1@demo.com') do |u|
    # --- ¡CORRECCIÓN AÑADIDA! ---
    u.name = "Juan Pérez (Cliente)"
    u.password = 'cliente123'
    u.password_confirmation = 'cliente123'
    u.role = :cliente
  end

  Cliente.find_or_create_by!(cuit_cliente: '20-11222333-4') do |c|
    c.nombre_apellido_cliente = 'Juan Pérez (Cliente)'
    c.mail_cliente = 'cliente1@demo.com'
    c.direccion_cliente = 'Calle Falsa 123'
    c.telefono_cliente = '1122334455'
    c.user = user_cliente_1 # <-- Asociación clave
  end

  user_cliente_2 = User.find_or_create_by!(email: 'cliente2@demo.com') do |u|
    # --- ¡CORRECCIÓN AÑADIDA! ---
    u.name = "Maria García (Cliente)"
    u.password = 'cliente123'
    u.password_confirmation = 'cliente123'
    u.role = :cliente
  end

  Cliente.find_or_create_by!(cuit_cliente: '27-44555666-1') do |c|
    c.nombre_apellido_cliente = 'Maria García (Cliente)'
    c.mail_cliente = 'cliente2@demo.com'
    c.direccion_cliente = 'Avenida Siempreviva 742'
    c.telefono_cliente = '9988776655'
    c.user = user_cliente_2
  end
rescue ActiveRecord::RecordInvalid => e
  puts "ERROR al crear Cliente: #{e.message}"
end

puts "✅ #{Cliente.count} Clientes creados."
puts "✅ #{User.where(role: :cliente).count} usuarios de clientes creados."


# ------------------------------------
# 2. Consultores
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
# 4. Estados de Trámite
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
ESTADOS_DATA.each { |e| EstadoTramite.find_or_create_by!(e) }
puts "✅ #{EstadoTramite.count} Estados de Trámite creados/verificados."


# ------------------------------------
# 5. Trámites de Ejemplo
# ------------------------------------
puts "Creando Trámites de Ejemplo (LISTO)..."

# Recargamos los objetos desde la BD para asegurar que existan.
consultores = Consultor.all.to_a
tipos = TipoTramite.all.to_a
clientes_map = Cliente.all.index_by(&:mail_cliente) # <-- Mapeamos por email

# Asignaciones
juan, maria, lucia, carlos, santiago = consultores
visa, residencia, revalidacion, permiso = tipos

# Helper para generar códigos
gen_codigo = ->(seq) { "TR-%04d" % seq }

TRAMITES_DATA = [
  {
    codigo: gen_codigo[1], estado: "ingresado",
    fecha_inicio: 2.days.ago, monto: 1000,
    consultor: juan, tipo_tramite: visa, cliente_email: "cliente1@demo.com" # <-- Usamos email
  },
  {
    codigo: gen_codigo[2], estado: "asignado",
    fecha_inicio: 1.day.ago, monto: 1500,
    consultor: maria, tipo_tramite: residencia, cliente_email: "cliente2@demo.com" # <-- Usamos email
  },
  {
    codigo: gen_codigo[3], estado: "en_proceso",
    fecha_inicio: 3.days.ago, monto: 2500,
    consultor: lucia, tipo_tramite: visa, cliente_email: "cliente1@demo.com" # <-- Usamos email
  },
  {
    codigo: gen_codigo[4], estado: "suspendido",
    fecha_inicio: 5.days.ago, monto: 800,
    consultor: juan, tipo_tramite: revalidacion, cliente_email: "cliente2@demo.com" # <-- Usamos email
  },
  {
    codigo: gen_codigo[5], estado: "terminado",
    fecha_inicio: 7.days.ago, monto: 1200,
    consultor: maria, tipo_tramite: permiso, cliente_email: "cliente1@demo.com" # <-- Usamos email
  },
  {
    codigo: gen_codigo[6], estado: "cancelado",
    fecha_inicio: 9.days.ago, monto: 600,
    consultor: carlos, tipo_tramite: residencia, cliente_email: "cliente2@demo.com" # <-- Usamos email
  }
]

TRAMITES_DATA.each_with_index do |attrs, index|
  # Mapeamos los emails a los IDs de cliente
  cliente_id = clientes_map[attrs[:cliente_email]]&.id

  # Verificamos si el cliente existe ANTES de intentar crear el trámite
  if cliente_id.nil?
    puts "❌ ERROR: No se encontró el cliente '#{attrs[:cliente_email]}' para el Trámite ##{index + 1} (#{attrs[:codigo]}). Saltando..."
    next
  end

  data_for_creation = attrs.except(:consultor, :tipo_tramite, :cliente_email).merge(
    consultor_id: attrs[:consultor]&.id,
    tipo_tramite_id: attrs[:tipo_tramite]&.id,
    cliente_id: cliente_id # <-- Usamos el ID de cliente encontrado
  )

  begin
    Tramite.create!(data_for_creation)
  rescue ActiveRecord::RecordInvalid => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Validación): #{e.message}"
  rescue => e
    puts "❌ ERROR: Falló la creación del Trámite ##{index + 1} (#{attrs[:codigo]}):"
    puts "  Detalles del Error (Final): #{e.message}"
  end
end

puts "✅ #{Tramite.count} Trámites de Ejemplo creados."
puts "------------------------------------"
puts "Resumen: Base de datos cargada. Reinicia Rails y prueba la API."
puts "------------------------------------"

