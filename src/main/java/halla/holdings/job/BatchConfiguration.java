package halla.holdings.job;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.batch.BatchDataSourceInitializer;
import org.springframework.boot.autoconfigure.batch.BatchProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ResourceLoader;

import javax.sql.DataSource;

@Configuration
class BatchDataSourceConfig  {
//    @Bean(name = "oracleDataSource")
//    @Primary
//    @ConfigurationProperties(prefix = "spring.datasource.oracle")
//    public DataSource oracleDataSource() {
//        return DataSourceBuilder.create().build();
//    }
//
//    @Autowired
//    private BatchDataSourceInitializer holdingsBatchDataSourceInitializer =
//            new BatchDataSourceInitializer(oracleDataSource(), )

}
