import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rentem/main.dart';
import 'package:rentem/app/Data/Models/property_model.dart';

import '../../Utils/font_styles.dart';

class PropertyView extends ConsumerWidget {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Properties",
          style: FontStyles.heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.secondary,
      ),
      body: ValueListenableBuilder<Box<PropertyModel>>(
        valueListenable: HiveService.propertiesBox.listenable(),
        builder: (context, Box<PropertyModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                "No properties yet",
                style: FontStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          final properties = box.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.pushNamed('propertydetails', extra: property);
                  },
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: property.pics != null &&
                                property.pics!.isNotEmpty
                            ? Image.asset(
                                property.pics!.first,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: const Icon(Icons.home,
                                        size: 40, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                child: const Icon(Icons.home,
                                    size: 40, color: Colors.grey),
                              ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name ?? "Unnamed Property",
                                style: FontStyles.heading.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                property.address ?? "No address",
                                style: FontStyles.body.copyWith(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹${property.rentAmount?.toStringAsFixed(0) ?? '0'} / month",
                                style: FontStyles.heading.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
        icon: Icon(Icons.delete, color: theme.colorScheme.error),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Delete Property"),
              content: Text(
                "Are you sure you want to delete '${property.name ?? 'this property'}'?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text("Delete"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await property.delete();
          }
        },
      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('addproperty');
        },
        icon: Icon(
          Icons.add,
          color: theme.canvasColor,
        ),
        label: Text(
          'ADD',
          style: FontStyles.heading.copyWith(
            fontSize: 18,
            color: theme.canvasColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
