import {
  Body,
  Controller,
  Delete,
  Post,
  Put,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ApiBody, ApiTags } from '@nestjs/swagger';
import { ProductService } from '../services/product.service';
import { ProductDto } from '../entities/dtos/product.dto';
import { IProduct } from '../entities/interfaces/product.interface';

@ApiTags('Product')
@Controller('product')
export class ProductController {
  constructor(private readonly productService: ProductService) {}

  @Post()
  @ApiBody({ type: ProductDto })
  async createProduct(@Body() req: IProduct) {
    try {
      return await this.productService.createProduct(req);
    } catch (err) {
      throw new ServiceUnavailableException(
        'Product service is unavailable',
      );
    }
  }

  @Put()
  @ApiBody({ type: ProductDto })
  async updateProduct(@Body() req: IProduct) {
    try {
      return await this.productService.updateProduct(req);
    } catch (err) {
      throw new ServiceUnavailableException(
        'Product service is unavailable',
      );
    }
  }

  @Delete()
  @ApiBody({ type: ProductDto })
  async deleteProduct(@Body() req: IProduct) {
    try {
      return await this.productService.deleteProduct(req);
    } catch (err) {
      throw new ServiceUnavailableException(
        'Product service is unavailable',
      );
    }
  }
}
