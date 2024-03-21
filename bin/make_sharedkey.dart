import 'package:at_client/at_client.dart';
import 'package:args/args.dart';
import 'package:at_utils/at_utils.dart';
import 'package:dart_playground/util.dart';

Future<void> main(List<String> arguments) async {
  // get atsign argument from ArgsParser
  AtSignLogger.root_level = 'info';
  final ArgParser argsParser = ArgParser();
  argsParser.addOption('sharedby',
      abbr: 'b', help: 'Owner of key', mandatory: true);
  argsParser.addOption('sharedwith',
      abbr: 'w', help: 'Recipient', mandatory: true);
  argsParser.addOption('name',
      abbr: 'k',
      help: 'Name of the AtKey',
      mandatory: false,
      defaultsTo: 'test');
  argsParser.addOption('value',
      abbr: 'v',
      help: 'Value',
      mandatory: false,
      defaultsTo: 'some encrypted value !!! 123');
  argsParser.addOption('namespace',
      abbr: 'n',
      help: 'Namespace',
      mandatory: false,
      defaultsTo: 'dart_playground');

  final ArgResults argResults;
  try {
    argResults = argsParser.parse(arguments);
  } catch (e) {
    print(argsParser.usage);
    return;
  }

  final String sharedByAtSign = argResults['sharedby'];
  final String sharedWithAtSign = argResults['sharedwith'];
  final String atKeyName = argResults['name'];
  final String atKeyValue = argResults['value'];
  final String namespace = argResults['namespace'];

  final AtClient atClient = await onboard(sharedByAtSign);

  AtKey atKey = AtKey()
        ..key = atKeyName
        ..sharedBy = sharedByAtSign
        ..sharedWith = sharedWithAtSign
        ..namespace = namespace // default namespace
      ;

  Metadata metadata = Metadata()
        ..ttl = 1000*60*10 // 10 minutes
        ..ccd = true

        ..ttr = 1000 * 1 * 60 // 1 minute
      ;

  atKey.metadata = metadata;

  print('Putting ${atKey.toString()} with value $atKeyValue');

  bool success = await atClient.put(atKey, atKeyValue, putRequestOptions: PutRequestOptions()..useRemoteAtServer=true);
  if (success) {
    print('Success');
  } else {
    print('Failed');
  }
  // atClient.syncService.sync();
}
