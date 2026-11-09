import '../data/piston_repository.dart';
import '../viewmodels/ajustes_viewmodel.dart';
import '../viewmodels/taller_viewmodel.dart';

final _repo = PistonRepository();
final taller = TallerViewModel(_repo);
final ajustes = AjustesViewModel(_repo);
