enum FlavorAppType {
  client(
    androidClientId: '711796199152-05m93odsde25vu2v7vsr4p2p5i3bvaud.apps.googleusercontent.com',
    webClientId: '711796199152-i0iuh8rvglm0jcgsbae80m9m7cc02pqe.apps.googleusercontent.com',
  ),

  admin(
    androidClientId: '1059981387216-f9jvep11pcjfg96jcm1nb3k1jh9ef8ed.apps.googleusercontent.com',
    webClientId: '1059981387216-4ua68c1mbrbin6a4f8cao6stnbugl6e3.apps.googleusercontent.com',
  );

  const FlavorAppType({
    required this.androidClientId,
    required this.webClientId,
  });

  final String androidClientId;
  final String webClientId;

}
