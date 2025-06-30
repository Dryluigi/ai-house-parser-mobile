import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';
import 'package:house_parser_mobile/features/house/presentation/pages/house_detail/house_detail_page.dart';

class HouseListItem extends StatelessWidget {
  final Function() refreshList;
  final HouseDataResponse data;

  const HouseListItem({
    super.key,
    required this.data,
    required this.refreshList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HouseDetailPage(houseId: data.id),
          ),
        ).then((value) => refreshList());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(12.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: data.getImageUrl(),
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[500],
                    size: 40,
                  ),
                ),
              ),
            ),

            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.number,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.address?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          data.address!,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    Text(
                      data.formatPriceRupiah().isEmpty
                          ? 'Belum diset'
                          : data.formatPriceRupiah(),
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
