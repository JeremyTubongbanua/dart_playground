import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_utils/at_utils.dart';
import 'package:dart_playground/util.dart';

bool isReservedAtKey(final String atSign, final String atKeyStr) {
  return atKeyStr == '$atSign:signing_privatekey$atSign' || atKeyStr == 'public:signing_publickey$atSign' || atKeyStr == 'public:publickey$atSign';
}

Future<void> main(List<String> arguments) async {
  // get atsign argument from ArgsParser
  AtSignLogger.root_level = 'SEVERE';
  final ArgParser argsParser = ArgParser();
  argsParser.addOption('atsign', abbr: 'a', help: 'Atsign to clear keys for', mandatory: true);

  final ArgResults argResults;
  try {
    argResults = argsParser.parse(arguments);
  } catch (e) {
    print(argsParser.usage);
    return;
  }

  final String atSign = argResults['atsign'];

  final AtClient atClient = await onboard(atSign);

  atClient.getAtKeys(sharedBy: atSign).then((atkeys) {
    int deleted = 0;
    for (var atkey in atkeys) {
      bool isReserved = isReservedAtKey(atSign, atkey.toString());
      print(isReserved ? "${atkey.toString()} is reserved" : "Deleting ${atkey.toString()}");
      if (!isReserved) {
        atClient.delete(atkey);
        deleted++;
      }

    }
    print("atkeys found: ${atkeys.length}");
    print("atkeys deleted: $deleted");
  });

  atClient.syncService.sync();

  return;
}
