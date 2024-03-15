/*----------------TextField---------------*/

// Librerías base
import 'package:flutter/material.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:provider/provider.dart';

///Create the text field for the e-mail
class TextFieldCompany extends StatelessWidget {
  ///Constructor
  const TextFieldCompany(this._searchBoxWidth, this.valueText, {Key? key})
      : super(key: key);

  final double _searchBoxWidth;

  final String valueText;

  @override
  Widget build(BuildContext context) {
    final providerCompany = Provider.of<ProviderSearch>(context);
    return SizedBox(
      width: _searchBoxWidth,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: TextFormField(
          initialValue: providerCompany.searchFilter,
          enableSuggestions: false,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              labelText: valueText),
          onChanged: providerCompany.changeSearchFilter,
          validator: (value) => null,
        ),
      ),
    );
  }
}
