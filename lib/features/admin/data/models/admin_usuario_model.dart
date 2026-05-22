class AdminUsuarioModel {
  final String id;
  final String? nombres;
  final String? apellidos;
  final String? nombreUsuario;
  final String? email;
  final String? fotoPerfil;
  final String? biografia;
  final String rol;
  final bool esActivo;
  final bool esVerificado;
  final int pubCount;
  final int seguidoresCount;
  final int reportesPendientes;
  final DateTime? fechaRegistro;
  final DateTime? ultimaConexion;
  final DateTime? banHasta;
  final String? motivoBan;

  const AdminUsuarioModel({
    required this.id,
    this.nombres,
    this.apellidos,
    this.nombreUsuario,
    this.email,
    this.fotoPerfil,
    this.biografia,
    required this.rol,
    required this.esActivo,
    required this.esVerificado,
    required this.pubCount,
    required this.seguidoresCount,
    required this.reportesPendientes,
    this.fechaRegistro,
    this.ultimaConexion,
    this.banHasta,
    this.motivoBan,
  });

  /// true si el ban es temporal y aún no venció
  bool get esBanTemporal =>
      !esActivo && banHasta != null && banHasta!.isAfter(DateTime.now());

  /// true si el ban es definitivo
  bool get esBanDefinitivo => !esActivo && banHasta == null;

  String get nombreCompleto {
    final n = '${nombres ?? ''} ${apellidos ?? ''}'.trim();
    return n.isNotEmpty ? n : nombreUsuario ?? 'Sin nombre';
  }

  factory AdminUsuarioModel.fromJson(Map<String, dynamic> j) {
    return AdminUsuarioModel(
      id:                  j['id_usuario'] as String,
      nombres:             j['nombres']    as String?,
      apellidos:           j['apellidos']  as String?,
      nombreUsuario:       j['nombre_usuario'] as String?,
      email:               j['email']      as String?,
      fotoPerfil:          j['foto_perfil_url'] as String?,
      biografia:           j['biografia']  as String?,
      rol:                 j['rol']        as String? ?? 'usuario',
      esActivo:            j['es_activo']  as bool? ?? true,
      esVerificado:        j['es_verificado'] as bool? ?? false,
      pubCount:            (j['pub_count_real'] as num?)?.toInt() ?? 0,
      seguidoresCount:     (j['seguidores_count_real'] as num?)?.toInt() ?? 0,
      reportesPendientes:  (j['reportes_pendientes'] as num?)?.toInt() ?? 0,
      fechaRegistro:       j['fecha_registro'] != null
          ? DateTime.tryParse(j['fecha_registro'] as String)
          : null,
      ultimaConexion:      j['ultima_conexion'] != null
          ? DateTime.tryParse(j['ultima_conexion'] as String)
          : null,
      banHasta:            j['ban_hasta'] != null
          ? DateTime.tryParse(j['ban_hasta'] as String)
          : null,
      motivoBan:           j['motivo_ban'] as String?,
    );
  }
}