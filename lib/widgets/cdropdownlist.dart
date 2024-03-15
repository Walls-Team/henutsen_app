// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// ------------Widget para menú desplegable----------------
// --------------------------------------------------------

import 'package:flutter/material.dart';

/// Widget para menú desplegable
Widget customDropDownList<T>(BuildContext context, Function update,
        String? fieldValue, List<String> items) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: fieldValue,
        icon:
            Icon(Icons.arrow_downward, color: Theme.of(context).highlightColor),
        elevation: 16,
        style: const TextStyle(fontSize: 14, color: Colors.brown),
        onChanged: (val) => update(val),
        items: items
            .map<DropdownMenuItem<String>>((value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList(),
      ),
    );
